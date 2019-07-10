import java.util.Timer;
import java.util.TimerTask;
import java.util.Date;
import java.text.SimpleDateFormat;
import java.net.URL;
import java.net.HttpURLConnection;
import java.io.File;
import java.io.InputStream;
import java.nio.file.StandardCopyOption;
import java.nio.file.Files;

public class Downloader {

    
    private static final String CAMERA_HOST = "CAMERA_HOST";
    private static final String CAMERA_USER = "CAMERA_USER";
    private static final String CAMERA_PWD = "CAMERA_PWD";
    private static final String OUT_DIRECTORY = "OUT_DIRECTORY";
    private static final String ENDPOINT_FORMAT = "http://%s/snapshot.cgi?user=%s&pwd=%s";
    
    static class DownloaderTask extends TimerTask {

	SimpleDateFormat prefixFmt = new SimpleDateFormat("yyyyMMddHH");
	SimpleDateFormat nameFmt = new SimpleDateFormat("yyyyMMddHHmmss");
		
	private final String endpoint;
	private final String outDir;

	DownloaderTask(String endpoint, String outDir) {	    
	    this.endpoint = endpoint;
	    this.outDir = outDir;
	}
	
	@Override
	public void run() {
	    Date now = new Date();
	    String prefix = prefixFmt.format(now);
	    String name = nameFmt.format(now) + ".jpg";
	    File outDirFile = new File(outDir);
	    try {
		File prefixFile = new File(outDirFile, prefix);
		prefixFile.mkdirs();
		File outFile = new File(prefixFile, name);
		URL url = new URL(endpoint);
		HttpURLConnection connection = (HttpURLConnection)url.openConnection();
		connection.setRequestMethod("GET");
		connection.connect();
		int code = connection.getResponseCode();
		if (code == 200) {
		    try(InputStream inputStream = connection.getInputStream()) {
			Files.copy(inputStream, outFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
		    }
		} else {
		    System.err.format("Received a non-200 response! %s", code);
		}
	    } catch (Exception e) {
		System.err.println("Download failed: " + e.getMessage());
	    }
	}
    }

    private static void checkVar(String var, String val) {
	if (val == null || "".equals(val)) {
	    System.err.format("%s environment variable must be set", var);
	    System.exit(1);
	}
    }

    public static void main(String args[]) {
	String host = System.getenv(CAMERA_HOST);
	String user = System.getenv(CAMERA_USER);
	String pwd = System.getenv(CAMERA_PWD);
	String outDir = System.getenv(OUT_DIRECTORY);

	checkVar(CAMERA_HOST, host);
	checkVar(CAMERA_USER, user);
	checkVar(CAMERA_PWD, pwd);
	checkVar(OUT_DIRECTORY, outDir);

	String endpoint = String.format(ENDPOINT_FORMAT, host, user, pwd);
	
	Timer timer = new Timer("Downloader");

	timer.schedule(new DownloaderTask(endpoint, outDir), 0, 1000);
    }
}
