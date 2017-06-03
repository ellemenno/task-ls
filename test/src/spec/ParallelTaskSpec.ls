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
            var progress:Number = 0;
            var callback:Function = function(task:Task, percent:Number) { progress = percent; };

            var a:TestTask = new TestTask();
            var b:TestTask = new TestTask();
            var c:TestTask = new TestTask();

            var testParallel:ParallelTask = new ParallelTask();
            testParallel.addTaskStateCallback(TaskState.REPORTING, callback);

            testParallel.addTask(a);
            testParallel.addTask(b);
            testParallel.addTask(c);

            testParallel.start();
            it.expects(progress).toEqual(0/3);

            a.do_complete();
            it.expects(progress).toEqual(1/3);

            b.do_complete();
            it.expects(progress).toEqual(2/3);

            c.do_complete();
            it.expects(progress).toEqual(3/3);
        }

        private static function finish_with_all():void
        {
            var a:TestTask = new TestTask();
            var b:TestTask = new TestTask();
            var c:TestTask = new TestTask();

            var testParallel:ParallelTask = new ParallelTask();
            testParallel.addTask(a);
            testParallel.addTask(b);
            testParallel.addTask(c);

            testParallel.start();
            it.expects(testParallel.currentState).toEqual(TaskState.RUNNING);

            a.do_complete();
            b.do_complete();
            c.do_complete();
            it.expects(testParallel.currentState).toEqual(TaskState.COMPLETED);
        }

        private static function fault_on_subfault():void
        {
            var a:TestTask = new TestTask();
            var b:TestTask = new TestTask();
            var c:TestTask = new TestTask();

            var testParallel:ParallelTask = new ParallelTask();
            testParallel.addTask(a);
            testParallel.addTask(b);
            testParallel.addTask(c);

            testParallel.start();
            it.expects(testParallel.currentState).toEqual(TaskState.RUNNING);

            c.do_fault('fail fast!');
            it.expects(testParallel.currentState).toEqual(TaskState.FAULT);
        }
    }
}
