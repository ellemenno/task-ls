package
{
    import pixeldroid.bdd.Spec;
    import pixeldroid.bdd.Thing;

    import pixeldroid.task.TaskVersion;


    public static class TaskLibSpec
    {
        private static const it:Thing;

        public static function specify(specifier:Spec):void
        {
            it = specifier.describe('Task lib');

            it.should('be versioned', be_versioned);
        }


        private static function be_versioned():void
        {
            it.expects(TaskVersion.version).toPatternMatch('(%d+).(%d+).(%d+)', 3);
        }
    }
}
