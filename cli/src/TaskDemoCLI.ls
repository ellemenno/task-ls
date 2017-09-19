package
{
    import system.application.ConsoleApplication;

    import pixeldroid.task.SequentialTask;
    import pixeldroid.task.SingleTask;
    import pixeldroid.task.Task;
    import pixeldroid.task.TaskState;


    public class TaskDemoCLI extends ConsoleApplication
    {
        override public function run():void
        {
            trace(this.getFullTypeName());

            var t1:Task = new Task1();
            var t2:Task = new Task2();
            var t3:Task = new Task3();

            var sequence:SequentialTask = new SequentialTask();
            sequence.label = 'sequence';

            sequence.addTaskStateCallback(TaskState.REPORTING, onProgress);
            sequence.addTaskStateCallback(TaskState.RUNNING, onStart);
            sequence.addTaskStateCallback(TaskState.FAULT, onFault);
            sequence.addTaskStateCallback(TaskState.COMPLETED, onComplete);

            sequence.addSubTaskStateCallback(TaskState.RUNNING, onStart);
            sequence.addSubTaskStateCallback(TaskState.FAULT, onFault);
            sequence.addSubTaskStateCallback(TaskState.COMPLETED, onComplete);

            sequence.addTask(t1);
            sequence.addTask(t2);
            sequence.addTask(t3);

            sequence.start();
        }

        private function onStart(task:Task):void
        {
            trace('task', task.label, 'has started');
        }

        private function onProgress(task:Task, percent:Number):void
        {
            trace('task', task.label, 'is', (Math.round(percent*100)) +'% complete');
        }

        private function onFault(task:Task, message:String):void
        {
            trace('fault in task', task.label +':', message);
        }

        private function onComplete(task:Task):void
        {
            trace('task', task.label, 'has completed');
        }
    }


    private class Task1 extends SingleTask
    {
        public function Task1() { label = 'uno'; }

        override protected function performTask():void
        {
            trace('task', label, 'performing its task..');
            complete();
        }
    }

    private class Task2 extends SingleTask
    {
        public function Task2() { label = 'dos'; }

        override protected function performTask():void
        {
            trace('task', label, 'performing its task..');
            complete();
        }
    }

    private class Task3 extends SingleTask
    {
        public function Task3() { label = 'tres'; }

        override protected function performTask():void
        {
            trace('task', label, 'performing its task..');
            // fault('task ' +label +' demonstrating a fault.');
            complete();
        }
    }
}
