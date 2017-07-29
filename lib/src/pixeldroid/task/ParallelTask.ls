package pixeldroid.task
{
    import pixeldroid.task.MultiTask;
    import pixeldroid.task.Task;
    import pixeldroid.task.TaskState;


    public class ParallelTask extends MultiTask
    {
        override protected function performTask():void
        {
            // FIXME: this is not parallel; need to look at using system.Coroutine
            for each (var task:Task in tasks)
            {
                if (canStartSubTask(task))
                    task.start();

                processAndAnnounceProgress();

                if (currentState == TaskState.FAULT)
                    return;
            }

            complete();
        }

        override protected function onSubTaskComplete(task:Task):void
        {
            super.onSubTaskComplete(task);

            if (numProcessed == numTasks)
                complete();
        }

        override protected function onSubTaskFault(task:Task, message:String):void
        {
            super.onSubTaskFault(task, message);

            fault(message);
        }
    }
}
