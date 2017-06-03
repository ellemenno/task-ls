package
{
    import system.application.ConsoleApplication;
    import system.Process;

    import pixeldroid.bdd.SpecExecutor;

    import MultiTaskSpec;
    import ParallelTaskSpec;
    import SequentialTaskSpec;
    import SingleTaskSpec;
    import TaskLibSpec;


    public class TaskTest extends ConsoleApplication
    {
        override public function run():void
        {
            SpecExecutor.parseArgs();

            var returnCode:Number = SpecExecutor.exec([
                TaskLibSpec,
                SingleTaskSpec,
                MultiTaskSpec,
                SequentialTaskSpec,
                ParallelTaskSpec
            ]);

            Process.exit(returnCode);
        }
    }

}
