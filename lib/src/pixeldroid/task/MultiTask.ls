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
            var count:Number = 0;

            for each (var task:Task in group.tasks)
            {
                if ((task is TaskGroup) && descend)
                {
                    count += countTasks(task as TaskGroup);
                }
                else
                {
                    count += 1;
                }
            }

            return count;
        }

        private static function countProcessed(group:TaskGroup, descend:Boolean = false):Number
        {
            var count:Number = group.numProcessed;

            for each (var task:Task in group.tasks)
            {
                if (task is TaskGroup)
                    count += TaskGroup(task).numProcessed;
            }

            return count;
        }

        private static const bar:String   = '─';
        private static const elbow:String = '└';
        private static const pipe:String  = '│';
        private static const space:String = ' ';
        private static const tee:String   = '├';

        private static function renderTaskTree(group:TaskGroup, indent:String = ''):String
        {
            var tree:String = (indent == '') ? group.label +'\n' : '';
            var lastTask:Task = group.tasks[group.tasks.length - 1];
            var branchChar:String;
            var indentChar:String;

            for each (var task:Task in group.tasks)
            {
                branchChar = (task == lastTask) ? elbow : tee;
                tree += indent +branchChar +bar +task.label +'\n';

                if (task is TaskGroup)
                {
                    indentChar = (task == lastTask) ? space : pipe;
                    tree += renderTaskTree(TaskGroup(task), (indent +indentChar +space));
                }
            }

            return tree;
        }


        public function set tasks(value:Vector.<Task>):void { _tasks = value; }
        public function get tasks():Vector.<Task> { return _tasks; }

        public function get taskTree():String { return MultiTask.renderTaskTree(this); }

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


        protected function startSubTask(task:Task):Boolean
        {
            if (task == null)
            {
                fault("Cannot start a null task");
                return false;
            }

            var started:Boolean = false;

            if (task.enabled)
            {
                connectCallbacks(task);
                task.start();
                started = true;
            }
            else
            {
                // disabled tasks count as already completed
                processAndAnnounceProgress();
                started = false;
            }

            return started;
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


        private function processAndAnnounceProgress():void
        {
            _numProcessed++;
            progress(_numProcessed / numTasks);
        }
    }
}
