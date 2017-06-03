package pixeldroid.task
{
    import system.Debug;

    import pixeldroid.task.MultiTask;
    import pixeldroid.task.Task;
    import pixeldroid.task.TaskState;


    public class ParallelTask extends MultiTask
    {
        override protected function performTask():void
        {
            startAllTasks();
        }

        override protected function onSubTaskComplete(task:Task):void
        {
            super.onSubTaskComplete(task);

            if (currentState == TaskState.FAULT)
                return;

            if (numProcessed == numTasks)
                complete();
        }

        override protected function onSubTaskFault(task:Task, message:String):void
        {
            super.onSubTaskFault(task, message);
            fault(message);
        }


        private function startAllTasks():void
        {
            var numStarted:Number = 0;

            for each (var task:Task in tasks)
            {
                if (startSubTask(task))
                    numStarted++;
            }

            if (numStarted == 0)
                complete();
        }

    }
}
