public class TasksCronJob implements Schedulable {

    public void execute(SchedulableContext sc) {
        List<Task> tasks = [SELECT Id, Subject, Description 
                            FROM Task];

        List<Task> matchedTasks = new List<Task>();

        for (Task t : tasks) {
            if (t.Description == 'Event Code 43 not found') {
                matchedTasks.add(t);
            }
        }

        if (!matchedTasks.isEmpty()) {
            Syntilio.UpsertToDatabase.deleteAction(matchedTasks, false);
        } 
    }
}
