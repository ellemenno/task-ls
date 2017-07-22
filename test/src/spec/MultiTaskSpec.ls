package
{
    import pixeldroid.bdd.Spec;
    import pixeldroid.bdd.Thing;

    import pixeldroid.task.MultiTask;
    import pixeldroid.task.Task;
    import pixeldroid.task.TaskState;

    import TestTask;


    public static class MultiTaskSpec
    {
        private static var it:Thing;

        public static function specify(specifier:Spec):void
        {
            it = specifier.describe('MutliTask');

            it.should('render a view of the task tree', render_tree);
            it.should('add tasks to the group', add_tasks);
            it.should('not allow the same task to be added more than once', add_tasks_idempotently);
            it.should('remove tasks from the group', remove_tasks);
            it.should('provide access to the tasks in the group', access_tasks);
            it.should('count the number of top-level tasks in the group', count_top_tasks);
            it.should('count all the nested tasks in the group', count_nested_tasks);
            it.should('know how many top-level tasks have been processed', count_processed_top_tasks);
            it.should('know how many nested tasks have been processed', count_processed_nested_tasks);
            it.should('connect callbacks to state change delegates', connect_callbacks);
            it.should('disconnect callbacks from state change delegates', disconnect_callbacks);
        }

        private static function render_tree():void
        {
            var m1:MultiTask = new MultiTask(); m1.label = 'MultiTask 1';
            var m2:MultiTask = new MultiTask(); m2.label = 'MultiTask 2';
            var m3:MultiTask = new MultiTask(); m3.label = 'MultiTask 3';
            var t1:TestTask = new TestTask();   t1.label = 'SingleTask 1';
            var t2:TestTask = new TestTask();   t2.label = 'SingleTask 2';
            var t3:TestTask = new TestTask();   t3.label = 'SingleTask 3';

            m3.addTask(t1);
            m3.addTask(t2);
            m3.addTask(t3);

            m2.addTask(t1);
            m2.addTask(t2);
            m2.addTask(m3);

            m1.addTask(t1);
            m1.addTask(m2);
            m1.addTask(t2);
            m1.addTask(t3);

            var renderedTree:Vector.<String> = [
                'MultiTask 1',
                '├─SingleTask 1',
                '├─MultiTask 2',
                '│ ├─SingleTask 1',
                '│ ├─SingleTask 2',
                '│ └─MultiTask 3',
                '│   ├─SingleTask 1',
                '│   ├─SingleTask 2',
                '│   └─SingleTask 3',
                '├─SingleTask 2',
                '└─SingleTask 3',
                ''
            ];

            it.expects(m1.taskTree).toEqual(renderedTree.join('\n'));
        }

        private static function add_tasks():void
        {
            var mt:MultiTask = new MultiTask();
            var t:TestTask = new TestTask();

            it.expects(mt.numTasks).toEqual(0);
            mt.addTask(t);
            it.expects(mt.numTasks).toEqual(1);
        }

        private static function add_tasks_idempotently():void
        {
            var mt:MultiTask = new MultiTask();
            var t:TestTask = new TestTask();

            it.expects(mt.numTasks).toEqual(0);
            mt.addTask(t);
            mt.addTask(t); // should have no effect
            it.expects(mt.numTasks).toEqual(1);
        }

        private static function remove_tasks():void
        {
            var mt:MultiTask = new MultiTask();
            var t:TestTask = new TestTask();

            mt.removeTask(t); // should have no effect
            mt.addTask(t);
            it.expects(mt.numTasks).toEqual(1);
            mt.removeTask(t);
            it.expects(mt.numTasks).toEqual(0);
        }

        private static function access_tasks():void
        {
            var mt:MultiTask = new MultiTask();
            var v:Vector.<Task> = [];
            var t:TestTask = new TestTask();

            it.expects(mt.tasks.length).toEqual(0);
            v.push(t);
            mt.tasks = v;
            it.expects(mt.tasks.length).toEqual(1);
        }

        private static function count_top_tasks():void
        {
            var m1:MultiTask = new MultiTask();
            var m2:MultiTask = new MultiTask();
            var t1:TestTask = new TestTask();

            m2.addTask(t1);

            m1.addTask(t1);
            m1.addTask(m2);

            it.expects(m1.numTasks).toEqual(2);
        }

        private static function count_nested_tasks():void
        {
            var m1:MultiTask = new MultiTask();
            var m2:MultiTask = new MultiTask();
            var t1:TestTask = new TestTask();
            var t2:TestTask = new TestTask();

            m2.addTask(t1);
            m2.addTask(t2);

            m1.addTask(t1);
            m1.addTask(m2);

            it.expects(m1.totalTasks).toEqual(3);
        }

        private static function count_processed_top_tasks():void
        {
            var tm1:TestMultiTask = new TestMultiTask();
            var tm2:TestMultiTask = new TestMultiTask();
            var t1:TestTask = new TestTask();
            var t2:TestTask = new TestTask();
            var t3:TestTask = new TestTask();

            tm2.addTask(t2);
            tm2.addTask(t3);

            tm1.addTask(t1);
            tm1.addTask(tm2);

            it.expects(tm1.numProcessed).toEqual(0);
            tm2.do_subTask(t2); t2.do_complete();
            tm1.do_subTask(t1); t1.do_complete();
            it.expects(tm1.numProcessed).toEqual(1);
        }

        private static function count_processed_nested_tasks():void
        {
            var tm1:TestMultiTask = new TestMultiTask();
            var tm2:TestMultiTask = new TestMultiTask();
            var t1:TestTask = new TestTask();
            var t2:TestTask = new TestTask();
            var t3:TestTask = new TestTask();

            tm2.addTask(t2);
            tm2.addTask(t3);

            tm1.addTask(t1);
            tm1.addTask(tm2);

            it.expects(tm1.totalProcessed).toEqual(0);
            tm2.do_subTask(t2); t2.do_complete();
            tm1.do_subTask(t1); t1.do_complete();
            it.expects(tm1.totalProcessed).toEqual(2);
        }

        private static function connect_callbacks():void
        {
            var tm1:TestMultiTask = new TestMultiTask();
            var t1:TestTask = new TestTask();
            var t2:TestTask = new TestTask();
            var t3:TestTask = new TestTask();
            var callCounter:Number = 0;
            var callback:Function = function (task:Task):void { callCounter++; };

            tm1.addSubTaskStateCallback(TaskState.RUNNING, callback);

            tm1.addTask(t1); tm1.do_subTask(t1);
            tm1.addTask(t2); tm1.do_subTask(t2);
            tm1.addTask(t3); tm1.do_subTask(t3);

            it.expects(callCounter).toEqual(3);
        }

        private static function disconnect_callbacks():void
        {
            var tm:TestMultiTask = new TestMultiTask();
            var t1:TestTask = new TestTask();
            var t2:TestTask = new TestTask();
            var t3:TestTask = new TestTask();
            var callCounter:Number = 0;
            var callback:Function = function (task:Task):void { callCounter++; };

            tm.addSubTaskStateCallback(TaskState.RUNNING, callback);
            tm.addSubTaskStateCallback(TaskState.COMPLETED, callback);

            tm.addTask(t1); tm.do_subTask(t1);
            tm.addTask(t2); tm.do_subTask(t2);
            tm.addTask(t3); tm.do_subTask(t3);

            tm.removeSubTaskStateCallback(TaskState.COMPLETED, callback);

            t1.do_complete();
            t2.do_complete();
            t3.do_complete();

            it.expects(callCounter).toEqual(3);
        }
    }


    public class TestMultiTask extends MultiTask
    {
        override protected function performTask():void { /* no-op */ }
        public function do_subTask(task:Task):Boolean { return startSubTask(task); }
    }

}
