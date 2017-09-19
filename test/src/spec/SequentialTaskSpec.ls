package
{
    import pixeldroid.bdd.Spec;
    import pixeldroid.bdd.Thing;

    import pixeldroid.task.SequentialTask;
    import pixeldroid.task.Task;
    import pixeldroid.task.TaskState;

    import TestTask;


    public static class SequentialTaskSpec
    {
        private static const it:Thing;

        public static function specify(specifier:Spec):void
        {
            it = specifier.describe('SequentialTask');

            it.should('complete the sub-tasks in the order added', complete_in_order);
            it.should('announce progress updates when sub-tasks complete', announce_progress);
            it.should('complete when last sub-task completes', finish_with_last);
            it.should('fault at the first sub-task fault', fault_fast);
        }


        private static function complete_in_order():void
        {
            var completedTasks:Vector.<Number> = [];
            var callback:Function = function(task:Task) { completedTasks.push(task); };

            var a:Task = TestTask.completingTask;
            var b:Task = TestTask.completingTask;
            var c:Task = TestTask.completingTask;

            var testSequence:SequentialTask = new SequentialTask();
            testSequence.addSubTaskStateCallback(TaskState.COMPLETED, callback);

            testSequence.addTask(a);
            testSequence.addTask(b);
            testSequence.addTask(c);

            var numTasks:Number = testSequence.numTasks;
            testSequence.start();

            it.expects(testSequence.currentState).toEqual(TaskState.COMPLETED);

            it.asserts(completedTasks.length).isEqualTo(numTasks).or('number of completed tasks (' +completedTasks.length +') did not match number of added tasks (' +testSequence.numTasks +')');
            it.expects(completedTasks[0]).toEqual(a);
            it.expects(completedTasks[1]).toEqual(b);
            it.expects(completedTasks[2]).toEqual(c);
        }

        private static function announce_progress():void
        {
            var progressUpdates:Vector.<Number> = [];
            var callback:Function = function(task:Task, percent:Number) { progressUpdates.push(percent); };

            var a:Task = TestTask.completingTask;
            var b:Task = TestTask.completingTask;
            var c:Task = TestTask.completingTask;

            var testSequence:SequentialTask = new SequentialTask();
            testSequence.addTaskStateCallback(TaskState.REPORTING, callback);

            testSequence.addTask(a);
            testSequence.addTask(b);
            testSequence.addTask(c);

            var numTasks:Number = testSequence.numTasks;
            testSequence.start();

            var numUpdates:Number = progressUpdates.length;
            it.expects(numUpdates).toEqual(numTasks);
            it.expects(progressUpdates[0]).toEqual(1 / numUpdates);
            it.expects(progressUpdates[numUpdates - 1]).toEqual(1);
        }

        private static function finish_with_last():void
        {
            var a:Task = TestTask.completingTask;
            var b:Task = TestTask.completingTask;
            var c:Task = TestTask.completingTask;

            var testSequence:SequentialTask = new SequentialTask();
            testSequence.addTask(a);
            testSequence.addTask(b);
            testSequence.addTask(c);

            testSequence.start();

            it.expects(testSequence.currentState).toEqual(TaskState.COMPLETED);
            it.expects(a.currentState).toEqual(TaskState.COMPLETED);
            it.expects(b.currentState).toEqual(TaskState.COMPLETED);
            it.expects(c.currentState).toEqual(TaskState.COMPLETED);
        }

        private static function fault_fast():void
        {
            var a:Task = TestTask.faultingTask;
            var b:Task = TestTask.completingTask;
            var c:Task = TestTask.completingTask;

            var testSequence:SequentialTask = new SequentialTask();
            testSequence.addTask(a);
            testSequence.addTask(b);
            testSequence.addTask(c);

            testSequence.start();

            it.expects(testSequence.currentState).toEqual(TaskState.FAULT);
            it.expects(a.currentState).toEqual(TaskState.FAULT);
            it.expects(b.currentState).toEqual(TaskState.UNSTARTED);
            it.expects(c.currentState).toEqual(TaskState.UNSTARTED);
        }
    }

}
