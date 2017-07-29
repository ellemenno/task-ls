package pixeldroid.task
{
    import system.Debug;

    import pixeldroid.task.Task;
    import pixeldroid.task.TaskComplete;
    import pixeldroid.task.TaskFault;
    import pixeldroid.task.TaskProgress;
    import pixeldroid.task.TaskStart;
    import pixeldroid.task.TaskState;
    import pixeldroid.task.TaskStateLabel;


    public class SingleTask implements Task
    {
        private var _currentState:TaskState = TaskState.UNSTARTED;
        private var _enabled:Boolean = true;
        private var _label:String;

        private var _onTaskStart:TaskStart;
        private var _onTaskProgress:TaskProgress;
        private var _onTaskFault:TaskFault;
        private var _onTaskComplete:TaskComplete;


        public function get currentState():TaskState { return _currentState; }

        public function get enabled():Boolean { return _enabled; }
        public function set enabled(value:Boolean):void { _enabled = value; }

        public function get label():String
        {
            if (!_label)
                return this.getFullTypeName();

            return _label;
        }

        public function set label(value:String):void
        {
            _label = value;
        }

        public function addTaskStateCallback(state:TaskState, callback:Function):void
        {
            switch (state)
            {
                case TaskState.RUNNING:
                    _onTaskStart += callback;
                    break;

                case TaskState.REPORTING:
                    _onTaskProgress += callback;
                    break;

                case TaskState.COMPLETED:
                    _onTaskComplete += callback;
                    break;

                case TaskState.FAULT:
                    _onTaskFault += callback;
                    break;
            }
        }

        public function removeTaskStateCallback(state:TaskState, callback:Function):void
        {
            switch (state)
            {
                case TaskState.RUNNING:
                    _onTaskStart -= callback;
                    break;

                case TaskState.REPORTING:
                    _onTaskProgress -= callback;
                    break;

                case TaskState.COMPLETED:
                    _onTaskComplete -= callback;
                    break;

                case TaskState.FAULT:
                    _onTaskFault -= callback;
                    break;
            }
        }

        public function start():void
        {
            if (!_enabled)
                return;

            if (_currentState == TaskState.RUNNING)
                return;

            setCurrentState(TaskState.RUNNING);
            _onTaskStart(this);
            performTask();
        }

        public function toString():String
        {
            return label +' (' +TaskStateLabel.toLabel(_currentState) +')';
        }


        protected function performTask():void
        {
            fault('performTask method must be implemented by subclass');
        }

        protected function complete():void
        {
            if (_currentState != TaskState.RUNNING)
                return;

            setCurrentState(TaskState.COMPLETED);
            _onTaskComplete(this);
            clearCallbacks();
        }

        protected function fault(message:String = null):void
        {
            if (_currentState != TaskState.RUNNING)
                return;

            setCurrentState(TaskState.FAULT);
            _onTaskFault(this, message);
            clearCallbacks();
        }

        protected function progress(percent:Number):void
        {
            if (_currentState != TaskState.RUNNING)
                return;

            _onTaskProgress(this, percent);
        }

        protected function clearCallbacks():void
        {
            _onTaskStart = null;
            _onTaskProgress = null;
            _onTaskFault = null;
            _onTaskComplete = null;
        }


        private function setCurrentState(value:TaskState):void
        {
            _currentState = value;
        }
    }
}
