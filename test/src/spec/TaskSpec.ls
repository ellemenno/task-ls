package
{
    import pixeldroid.bdd.Spec;
    import pixeldroid.bdd.Thing;

    import pixeldroid.task.SingleTask;
    import pixeldroid.task.Task;
    import pixeldroid.task.TaskState;
    import pixeldroid.task.TaskVersion;


    public static class TaskSpec
    {
        private static const it:Thing = Spec.describe('Task');

        public static function describe():void
        {
            it.should('be versioned', be_versioned);
            it.should('be enabled by default', initialize_enabled);
            it.should('not start if disabled', not_start_if_disabled);
            it.should('provide a default label', have_default_label);
            it.should('provide a toString method', have_toString);
            it.should('announce when started', announce_start);
            it.should('announce when completed', announce_completed);
            it.should('announce when a fault occurs', announce_fault);
            it.should('announce progress', announce_progress);
        }


        private static function be_versioned():void
        {
            it.expects(TaskVersion.version).toPatternMatch('(%d+).(%d+).(%d+)', 3);
        }

        private static function initialize_enabled():void
        {
            var task:Task = new TestTask();
            it.expects(task.enabled).toBeTruthy();
        }

        private static function have_default_label():void
        {
            var task:Task = new TestTask();
            var label:String = 'test_label';
            it.expects(task.label).not.toBeEmpty();
            it.expects(task.label).not.toEqual(label);

            task.label = label;
            it.expects(task.label).toEqual(label);
        }

        private static function have_toString():void
        {
            var task:Task = new TestTask();
            task.label = 'test';
            it.expects(task.toString()).toEqual('test (unstarted)');
        }

        private static function not_start_if_disabled():void
        {
            var task:Task = new TestTask();
            task.enabled = false;
            task.start();
            it.expects(task.currentState).toEqual(TaskState.UNSTARTED);
        }

        private static function announce_start():void
        {
            var alerts:Number = 0;
            var task:Task = new TestTask();
            var callback:Function = function(task:Task) { alerts++; };

            task.addCallback(TaskState.RUNNING, callback);
            it.expects(task.currentState).toEqual(TaskState.UNSTARTED);

            task.start();
            task.start(); // should be idempotent

            it.expects(task.currentState).toEqual(TaskState.RUNNING);
            it.expects(alerts).toEqual(1);
        }

        private static function announce_completed():void
        {
            var alerts:Number = 0;
            var task:TestTask = new TestTask();
            var callback:Function = function(task:Task) { alerts++; };

            task.addCallback(TaskState.COMPLETED, callback);
            task.start();
            task.do_complete();

            it.expects(task.currentState).toEqual(TaskState.COMPLETED);
            it.expects(alerts).toEqual(1);
        }

        private static function announce_fault():void
        {
            var alerted:Boolean = false;
            var message:String = '';
            var task:TestTask = new TestTask();
            var callback:Function = function(task:Task, msg:String) { alerted = true; message = msg; };

            task.addCallback(TaskState.FAULT, callback);
            task.do_fault('fault tolerant'); // should have no effect prior to start
            it.expects(task.currentState).toEqual(TaskState.UNSTARTED);
            it.expects(alerted).toBeFalsey();
            it.expects(message).toBeEmpty();

            task.start();
            task.do_fault('fault aware');

            it.expects(task.currentState).toEqual(TaskState.FAULT);
            it.expects(alerted).toBeTruthy();
            it.expects(message).not.toBeEmpty();
        }

        private static function announce_progress():void
        {
            var alerted:Boolean = false;
            var percent:Number = 0;
            var task:TestTask = new TestTask();
            var callback:Function = function(task:Task, p:Number) { alerted = true; percent = p; };

            task.addCallback(TaskState.REPORTING, callback);
            task.start();
            task.do_progress(.57);

            it.expects(task.currentState).toEqual(TaskState.RUNNING);
            it.expects(alerted).toBeTruthy();
            it.expects(percent).toEqual(.57);
        }
    }

    public class TestTask extends SingleTask
    {
        override protected function performTask():void { /* no-op */ }
        public function do_complete():void { complete(); }
        public function do_fault(message:String):void { fault(message); }
        public function do_progress(percent:Number):void { progress(percent); }
    }
}
