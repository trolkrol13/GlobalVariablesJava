public class MainClass {

	class InternalClass {
		public static int testVariable = 0;
		class AnotherInternalClass {
			public static int internalVar = 0;
		}
		public static int testVar = 0;
	}

	public static int variable = 0;

	public synchronized void Change(int a)
	{
		if (a % 2 == 0)variable +=2
		else MainClass.variable -=2;   
	}

	public static volatile int valuee = 0;

	synchronized protected void CreateThread()
	{
		valuee = new MyThread(); 
		task.start();
	}

	public void run()
	{ 
		for(int i=0;i<10;i++)
		{
			Change(i);
			System.out.println("V = "+MainClass.variable+"\t i = "+i+"\t Thread Name "+this.getName());
		}
	}
	
	
	public static  int vvvv = 0;


	public static void main(String args[])
	{
		MainClass mc=new MainClass();
		mc.CreateThread();
		mc.CreateThread();
	}

	public synchronized void Change(int a)
	{
		if (a % 2 == 0)vvvv +=2
		else MainClass.vvvv -=2;   
	}

	public static volatile int valaaa = 0;

	synchronized protected void CreateThread()
	{
		valaaa = new MyThread(); 
		task.start();
	}

	public void run()
	{ 
		for(int i=0;i<10;i++)
		{
			Change(i);
			System.out.println("V = "+MainClass.vvvv+"\t i = "+i+"\t Thread Name "+this.getName());
		}
	}


	public static  int qqqq = 0;


	public static void main(String args[])
	{
		MainClass mc=new MainClass();
		mc.CreateThread();
		mc.CreateThread();
	}

	public synchronized void Change(int a)
	{
		if (a % 2 == 0)qqqq +=2
		else MainClass.qqqq -=2;   
	}

	public static volatile int vallll = 0;

	synchronized protected void CreateThread()
	
{		vallll = new MyThread(); 
		task.start();
	}

	public void run()
	{ 
		for(int i=0;i<10;i++)
		{
			Change(i);
			System.out.println("V = "+MainClass.qqqq+"\t i = "+i+"\t Thread Name "+this.getName());
		}
	}


	public static  int wwww = 0;


	public static void main(String args[])
	{
		MainClass mc=new MainClass();
		mc.CreateThread();
		mc.CreateThread();
	}

	public synchronized void Change(int a)
	{
		if (a % 2 == 0)wwww +=2
		else MainClass.wwww -=2;   
	}

	public static volatile int vayy = 0;

	synchronized protected void CreateThread()
	{
		vayy = new MyThread(); 
		task.start();
	}

	public void run()
	{ 
		for(int i=0;i<10;i++)
		{
			Change(i);
			System.out.println("V = "+MainClass.wwww+"\t i = "+i+"\t Thread Name "+this.getName());
		}
	}
	


	public static  int tttt = 0;


	public static void main(String args[])
	{
		MainClass mc=new MainClass();
		mc.CreateThread();
		mc.CreateThread();
	}

	public synchronized void Change(int a)
	{
		if (a % 2 == 0)tttt +=2
		else MainClass.tttt -=2;   
	}

	public static volatile int vapp = 0;

	synchronized protected void CreateThread()
	{
		vapp = new MyThread(); 
		task.start();
	}

	public void run()
	{ 
		for(int i=0;i<10;i++)
		{
			Change(i);
			System.out.println("V = "+MainClass.tttt+"\t i = "+i+"\t Thread Name "+this.getName());
		}
	}
}