package pixeldroid.task
{
    import pixeldroid.task.MultiTask;
    import pixeldroid.task.Task;
    import pixeldroid.task.TaskState;


    public class SequentialTask extends MultiTask
    {
        override protected function performTask():void
        {
            for each (var task:Task in tasks)
            {
                if (canStartSubTask(task))
                    task.start();
                else
                    processAndAnnounceProgress(); // disabled tasks still count as processed tasks

                if (currentState == TaskState.FAULT)
                    return;
            }

            fault('task sequence was unable to be performed');
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
