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

            it.should('start first sub-task when started', start_with_first);
            it.should('announce progress updates when sub-tasks complete', announce_progress);
            it.should('complete when last sub-task completes', finish_with_last);
            it.should('fault at the first sub-task fault', fault_fast);
        }


        private static function start_with_first():void
        {
            var a:TestTask = new TestTask();
            var b:TestTask = new TestTask();
            var c:TestTask = new TestTask();

            var testSequence:SequentialTask = new SequentialTask();
            testSequence.addTask(a);
            testSequence.addTask(b);
            testSequence.addTask(c);

            it.expects(a.currentState).toEqual(TaskState.UNSTARTED);
            it.expects(b.currentState).toEqual(TaskState.UNSTARTED);
            it.expects(c.currentState).toEqual(TaskState.UNSTARTED);

            testSequence.start();

            it.expects(a.currentState).toEqual(TaskState.RUNNING);
            it.expects(b.currentState).toEqual(TaskState.UNSTARTED);
            it.expects(c.currentState).toEqual(TaskState.UNSTARTED);
        }

        private static function announce_progress():void
        {
            var progress:Number = 0;
            var callback:Function = function(task:Task, percent:Number) { progress = percent; };

            var a:TestTask = new TestTask();
            var b:TestTask = new TestTask();
            var c:TestTask = new TestTask();

            var testSequence:SequentialTask = new SequentialTask();
            testSequence.addTaskStateCallback(TaskState.REPORTING, callback);

            testSequence.addTask(a);
            testSequence.addTask(b);
            testSequence.addTask(c);

            testSequence.start();
            it.expects(progress).toEqual(0/3);

            a.do_complete();
            it.expects(progress).toEqual(1/3);

            b.do_complete();
            it.expects(progress).toEqual(2/3);

            c.do_complete();
            it.expects(progress).toEqual(3/3);
        }

        private static function finish_with_last():void
        {
            var a:TestTask = new TestTask();
            var b:TestTask = new TestTask();
            var c:TestTask = new TestTask();

            var testSequence:SequentialTask = new SequentialTask();
            testSequence.addTask(a);
            testSequence.addTask(b);
            testSequence.addTask(c);

            testSequence.start();
            it.expects(testSequence.currentState).toEqual(TaskState.RUNNING);

            a.do_complete();
            b.do_complete();
            c.do_complete();
            it.expects(testSequence.currentState).toEqual(TaskState.COMPLETED);
        }

        private static function fault_fast():void
        {
            var a:TestTask = new TestTask();
            var b:TestTask = new TestTask();
            var c:TestTask = new TestTask();

            var testSequence:SequentialTask = new SequentialTask();
            testSequence.addTask(a);
            testSequence.addTask(b);
            testSequence.addTask(c);

            testSequence.start();
            it.expects(testSequence.currentState).toEqual(TaskState.RUNNING);

            a.do_fault('fail fast!');
            it.expects(testSequence.currentState).toEqual(TaskState.FAULT);
        }
    }

}
