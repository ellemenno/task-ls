package pixeldroid.task
{
    import system.Debug;

    import pixeldroid.task.MultiTask;
    import pixeldroid.task.Task;
    import pixeldroid.task.TaskState;


    public class SequentialTask extends MultiTask
    {
        private var currentTask:Number = 0;


        override protected function performTask():void
        {
            startNextTask();
        }

        override protected function onSubTaskComplete(task:Task):void
        {
            super.onSubTaskComplete(task);
            startNextTask();
        }

        override protected function onSubTaskFault(task:Task, message:String):void
        {
            super.onSubTaskFault(task, message);
            fault(message);
        }


        private function startNextTask():void
        {
            if (!hasMoreTasks)
                complete();

            else if (!startSubTask(nextTask))
                startNextTask();
        }

        private function get hasMoreTasks():Boolean
        {
            return tasks && (currentTask < tasks.length);
        }

        private function get nextTask():Task
        {
            var task:Task;

            if (hasMoreTasks)
                task = tasks[currentTask++] as Task;

            return task;
        }
    }
}
