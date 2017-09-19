package
{
    import pixeldroid.bdd.Spec;
    import pixeldroid.bdd.Thing;

    import pixeldroid.task.ParallelTask;
    import pixeldroid.task.Task;
    import pixeldroid.task.TaskState;

    import TestTask;


    public static class ParallelTaskSpec
    {
        private static const it:Thing;

        public static function specify(specifier:Spec):void
        {
            it = specifier.describe('ParallelTask');

            it.should('start all sub-tasks when started', start_them_all);
            it.should('announce progress updates when sub-tasks complete', announce_progress);
            it.should('complete when all sub-tasks are complete', finish_with_all);
            it.should('fault if any sub-task faults', fault_on_subfault);
        }


        private static function start_them_all():void
        {
            var a:TestTask = new TestTask();
            var b:TestTask = new TestTask();
            var c:TestTask = new TestTask();

            var testParallel:ParallelTask = new ParallelTask();
            testParallel.addTask(a);
            testParallel.addTask(b);
            testParallel.addTask(c);

            it.expects(a.currentState).toEqual(TaskState.UNSTARTED);
            it.expects(b.currentState).toEqual(TaskState.UNSTARTED);
            it.expects(c.currentState).toEqual(TaskState.UNSTARTED);

            testParallel.start();

            it.expects(a.currentState).toEqual(TaskState.RUNNING);
            it.expects(b.currentState).toEqual(TaskState.RUNNING);
            it.expects(c.currentState).toEqual(TaskState.RUNNING);
        }

        private static function announce_progress():void
        {
            var progress:Vector.<Number> = [];
            var callback:Function = function(task:Task, percent:Number) { progress.push(percent); };

            var a:Task = TestTask.completingTask;
            var b:Task = TestTask.completingTask;
            var c:Task = TestTask.completingTask;

            var testParallel:ParallelTask = new ParallelTask();
            testParallel.addTaskStateCallback(TaskState.REPORTING, callback);

            testParallel.addTask(a);
            testParallel.addTask(b);
            testParallel.addTask(c);

            testParallel.start();

            it.asserts(progress.length).isEqualTo(3);
            it.expects(progress[0]).toEqual(1/3);
            it.expects(progress[1]).toEqual(2/3);
            it.expects(progress[2]).toEqual(3/3);
        }

        private static function finish_with_all():void
        {
            var a:Task = TestTask.completingTask;
            var b:Task = TestTask.completingTask;
            var c:Task = TestTask.completingTask;

            var testParallel:ParallelTask = new ParallelTask();
            testParallel.addTask(a);
            testParallel.addTask(b);
            testParallel.addTask(c);

            testParallel.start();

            it.expects(testParallel.currentState).toEqual(TaskState.COMPLETED);
            it.expects(a.currentState).toEqual(TaskState.COMPLETED);
            it.expects(b.currentState).toEqual(TaskState.COMPLETED);
            it.expects(c.currentState).toEqual(TaskState.COMPLETED);
        }

        private static function fault_on_subfault():void
        {
            var a:Task = TestTask.completingTask;
            var b:Task = TestTask.faultingTask;
            var c:Task = TestTask.completingTask;

            var testParallel:ParallelTask = new ParallelTask();
            testParallel.addTask(a);
            testParallel.addTask(b);
            testParallel.addTask(c);

            testParallel.start();
            it.expects(testParallel.currentState).toEqual(TaskState.FAULT);
            it.expects(a.currentState).toEqual(TaskState.COMPLETED);
            it.expects(b.currentState).toEqual(TaskState.FAULT);
            it.expects(c.currentState).toEqual(TaskState.UNSTARTED);
        }
    }
}
