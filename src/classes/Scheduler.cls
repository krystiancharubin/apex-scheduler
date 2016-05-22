global class Scheduler implements Schedulable {

	private Job job;

	public Scheduler(Job job) {
		this.job = job;
	}

	global static Id schedule(String name, String cron, Type type){
		Job job;
		try {
			job = (Job) type.NewInstance();
		} catch(System.TypeException ex) {
			throw new SchedulerException(ex.getMessage(), ex);
		}
		Long unix = System.now().getTime();
		return System.schedule(name + unix, cron, new Scheduler(job));
	}

	global void execute(SchedulableContext sc){
		job.execute(sc);
	}

	public Interface Job {
		void execute(SchedulableContext sc);
	}

	public class SchedulerException extends Exception {}
}