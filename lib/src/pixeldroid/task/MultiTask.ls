package pixeldroid.task
{
    import pixeldroid.task.SingleTask;
    import pixeldroid.task.Task;
    import pixeldroid.task.TaskComplete;
    import pixeldroid.task.TaskFault;
    import pixeldroid.task.TaskGroup;
    import pixeldroid.task.TaskProgress;
    import pixeldroid.task.TaskStart;
    import pixeldroid.task.TaskState;
    import pixeldroid.task.TaskStateLabel;


    public class MultiTask extends SingleTask implements TaskGroup
    {
        private var _numProcessed:Number = 0;
        private var _tasks:Vector.<Task> = [];

        private var _onSubTaskStart:TaskStart;
        private var _onSubTaskProgress:TaskProgress;
        private var _onSubTaskFault:TaskFault;
        private var _onSubTaskComplete:TaskComplete;

        private static function countTasks(group:TaskGroup, descend:Boolean = false):Number
        {
            var count:Number = group.tasks.length;

            if (descend)
            {
                for each (var task:Task in group.tasks)
                {
                    if (task is TaskGroup)
                        count += countTasks(task as TaskGroup, descend) - 1; // don't count task group as task
                }
            }

            return count;
        }

        private static function countProcessed(group:TaskGroup, descend:Boolean = false):Number
        {
            var count:Number = group.numProcessed;

            if (descend)
            {
                for each (var task:Task in group.tasks)
                {
                    if (task is TaskGroup)
                        count += TaskGroup(task).numProcessed;
                }
            }

            return count;
        }

        private static const bar:String   = '─';
        private static const elbow:String = '└';
        private static const pipe:String  = '│';
        private static const space:String = ' ';
        private static const tee:String   = '├';

        private static function renderTaskTree(lines:Vector.<String>, group:TaskGroup, indent:String = ''):void
        {
            var lastTask:Task = group.tasks[group.tasks.length - 1];
            var branchChar:String;
            var indentChar:String;

            if (indent == '')
                lines.push(group.label +' (total tasks = ' +countTasks(group, true) +')');

            for each (var task:Task in group.tasks)
            {
                branchChar = (task == lastTask) ? elbow : tee;
                lines.push(indent +branchChar +bar +task.label);

                if (task is TaskGroup)
                {
                    indentChar = (task == lastTask) ? space : pipe;
                    renderTaskTree(lines, TaskGroup(task), (indent +indentChar +space));
                }
            }
        }


        public function set tasks(value:Vector.<Task>):void { _tasks = value; }
        public function get tasks():Vector.<Task> { return _tasks; }

        public function get taskTree():Vector.<String>
        {
            var lines:Vector.<String> = [];
            MultiTask.renderTaskTree(lines, this);

            return lines;
        }

        public function get numTasks():Number { return MultiTask.countTasks(this); }
        public function get totalTasks():Number { return MultiTask.countTasks(this, true); }

        public function get numProcessed():Number { return _numProcessed; }
        public function get totalProcessed():Number { return MultiTask.countProcessed(this, true); }

        public function addTask(task:Task):void
        {
            if (task && !_tasks.contains(task))
                _tasks.push(task);
        }

        public function removeTask(task:Task):void
        {
            if (task)
                _tasks.remove(task);
        }

        public function addSubTaskStateCallback(state:TaskState, callback:Function):void
        {
            switch (state)
            {
                case TaskState.RUNNING:
                    _onSubTaskStart += callback;
                    break;

                case TaskState.REPORTING:
                    _onSubTaskProgress += callback;
                    break;

                case TaskState.COMPLETED:
                    _onSubTaskComplete += callback;
                    break;

                case TaskState.FAULT:
                    _onSubTaskFault += callback;
                    break;
            }
        }

        public function removeSubTaskStateCallback(state:TaskState, callback:Function):void
        {
            switch (state)
            {
                case TaskState.RUNNING:
                    _onSubTaskStart -= callback;
                    break;

                case TaskState.REPORTING:
                    _onSubTaskProgress -= callback;
                    break;

                case TaskState.COMPLETED:
                    _onSubTaskComplete -= callback;
                    break;

                case TaskState.FAULT:
                    _onSubTaskFault -= callback;
                    break;
            }
        }


        override protected function clearCallbacks():void
        {
            _onSubTaskStart = null;
            _onSubTaskProgress = null;
            _onSubTaskFault = null;
            _onSubTaskComplete = null;

            super.clearCallbacks();

            _tasks.clear();
        }

        protected function canStartSubTask(task:Task):Boolean
        {
            if (task == null)
            {
                fault("Cannot start a null task");
                return false;
            }

            var canStart:Boolean = false;

            if (task.enabled)
            {
                connectCallbacks(task);
                canStart = true;
            }

            return canStart;
        }

        protected function connectCallbacks(task:Task):void
        {
            task.addTaskStateCallback(TaskState.RUNNING, onSubTaskStart);
            task.addTaskStateCallback(TaskState.REPORTING, onSubTaskProgress);
            task.addTaskStateCallback(TaskState.COMPLETED, onSubTaskComplete);
            task.addTaskStateCallback(TaskState.FAULT, onSubTaskFault);
        }

        protected function disconnectCallbacks(task:Task):void
        {
            task.removeTaskStateCallback(TaskState.RUNNING, onSubTaskStart);
            task.removeTaskStateCallback(TaskState.REPORTING, onSubTaskProgress);
            task.removeTaskStateCallback(TaskState.COMPLETED, onSubTaskComplete);
            task.removeTaskStateCallback(TaskState.FAULT, onSubTaskFault);
        }

        protected function onSubTaskStart(task:Task):void
        {
            _onSubTaskStart(task);
        }

        protected function onSubTaskProgress(task:Task, percent:Number):void
        {
            _onSubTaskProgress(task, percent);
        }

        protected function onSubTaskFault(task:Task, message:String):void
        {
            _onSubTaskFault(task, message);
            disconnectCallbacks(task);
        }

        protected function onSubTaskComplete(task:Task):void
        {
            _onSubTaskComplete(task);
            processAndAnnounceProgress();
            disconnectCallbacks(task);
        }

        protected function processAndAnnounceProgress():void
        {
            _numProcessed++;
            progress(_numProcessed / numTasks);
        }
    }
}
