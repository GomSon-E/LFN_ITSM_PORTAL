<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
	import="java.util.*, 
	        java.net.*,
			javax.servlet.http.*, 
        	org.json.simple.*,
            org.json.simple.parser.*,
            java.sql.*,  
        	java.text.SimpleDateFormat,
        	javax.sql.DataSource,
        	javax.naming.Context,
        	javax.naming.InitialContext,  
	    	java.io.BufferedReader,
	    	java.io.Reader,
	    	java.io.Writer,
	    	java.io.CharArrayReader,
	    	oracle.sql.CLOB,
	    	oracle.sql.BLOB,
	    	oracle.jdbc.OracleResultSet,   
        	org.apache.log4j.*,
        	org.apache.commons.io.*,
        	org.apache.commons.codec.*,
        	java.io.*,
        	java.nio.charset.StandardCharsets,
        	java.nio.file.*,
        	java.nio.file.Files,
        	java.security.*" %>  
<%! 
/*** COMMON ***/ 
public boolean isNull(Object val) {
	boolean rtn = false;
	if (val == null) rtn = true;
	else if (val instanceof java.lang.String && "".equals(val)) rtn = true;
	else if ("[]".equals(val.toString()) || "{}".equals(val.toString())) rtn = true; 
	return rtn;
}
public String nvl(String val, String rep) { //null일 경우 Replace값으로 치환
	String rtn = ""; 
	if (val == null) rtn = rep;
	else rtn = val;
	return rtn;
}
public String getDate() {
	String rtn = "2019-09-07";
	Calendar cal= Calendar.getInstance();
    int year = cal.get(Calendar.YEAR);
    int mon = cal.get(Calendar.MONTH) + 1;
    int day = cal.get(Calendar.DAY_OF_MONTH);

    rtn = year+"-";
    if(mon < 10) rtn += "0"+mon+"-";
    else rtn += mon+"-";
    
    if(day < 10) rtn += "0"+day;
    else rtn += day;
    
    return rtn; 		
}
public String getDateTime() {
	String rtn = "2019-09-07 16:42:21";
	Calendar cal= Calendar.getInstance();
    int year = cal.get(Calendar.YEAR);
    int mon = cal.get(Calendar.MONTH) + 1;
    int day = cal.get(Calendar.DAY_OF_MONTH);
    int hour = cal.get(Calendar.HOUR);
    int min = cal.get(Calendar.MINUTE);
    int sec = cal.get(Calendar.SECOND);

    rtn = year+"-";
    if(mon < 10) rtn += "0"+mon+"-";
    else rtn += mon+"-";
    
    if(day < 10) rtn += "0"+day;
    else rtn += day;
    
    rtn += " " + hour + ":" + min + ":" + sec;  
    
    return rtn; 		
}
public String getUUID(int len) {
	String rtn = "20190907164221dK2kdlkbi"; //시분초(14)+지정된자리수
	//UUID uuid = new UUID();
	String uid = (UUID.randomUUID()).toString();
	String ymd = "";
	String hms = "";
	Calendar cal= Calendar.getInstance();
    int year = cal.get(Calendar.YEAR);
    int mon = cal.get(Calendar.MONTH) + 1;
    int day = cal.get(Calendar.DAY_OF_MONTH);
    int hour = cal.get(Calendar.HOUR);
    int min = cal.get(Calendar.MINUTE);
    int sec = cal.get(Calendar.SECOND);
    ymd = ""+ year;
    ymd += fm(mon,"00");
    ymd += fm(day,"00");  
    hms = fm(hour,"00");  
    hms = fm(min,"00");  
    hms = fm(sec,"00");   
	
    if ( len < 8 ) rtn = uid.substring(0,len); 
    else if ( len < 14 ) rtn = ymd + (uid.substring(0,len-8));
    else rtn = ymd+hms+(uid.substring(0,len-14));
    return rtn; 		
}

public String fm(int val, String format) {
	if(format.equals("00")) {
		if(val < 10) return "0"+val;
		else return ""+val;
	}
	return "";
}

public String calgetWeekday(int day_of_week) {
	String m_week = "";
	if ( day_of_week == 1 ) m_week="일요일";
	else if ( day_of_week == 2 ) m_week="월요일";
	else if ( day_of_week == 3 ) m_week="화요일";
	else if ( day_of_week == 4 ) m_week="수요일";
	else if ( day_of_week == 5 ) m_week="목요일";
	else if ( day_of_week == 6 ) m_week="금요일";
	else if ( day_of_week == 7 ) m_week="토요일"; 
	else {
		Calendar cal= Calendar.getInstance();
		int day_of_week2 = cal.get ( Calendar.DAY_OF_WEEK );
		m_week = calgetWeekday(day_of_week2);
	}
return m_week; 
}
%>
<%! 
//static Logger logger2 = new Logger(); //Logger.getLogger("common.jsp");//.getRootLogger(); //
public Logger logger = new Logger(); 
public class Logger {
	boolean chkval; 
	String Userid; 
	
	Logger() {	 
	}
	
	void setUp(String userid) {

		Userid = userid;
		
		if("192053".equals(userid) || "mnight80".equals(userid))
		{
			chkval = true;
		}
		else
		{
			chkval = false;
		}
		
	}
	
	void error(String msg, Exception e) { 
		if (chkval) error( msg + "-" + e.toString());
	}
	
	void error(String msg) {
		if (chkval) {
			String msg2 = "E - " + getDateTime() + " " + getCaller() + " " + Userid + " - " + msg;
			System.out.println(msg2);
		    /*
			String dir = "D:\\ONLINEADMIN\\bin\\tomcat9_awe\\logs\\"; //C:\ONLINEADMIN\bin\tomcat9_awe\logs
			String dt = getDate();
			String fnm = "awelogger."+dt+".txt"; 
			String fullpath = dir + fnm;
			
			try {
				File newpath = new File(dir);
			    if (!newpath.exists()) {
			    	newpath.mkdirs();
			    }
			    File newfile = new File(fullpath);
			    if (!newfile.exists()) {
			    	newfile.createNewFile();
			    	Writer fw = null;
			    	fw = new OutputStreamWriter(new FileOutputStream(fullpath), StandardCharsets.UTF_8);
			    	fw.write( msg2 ); 
			    	fw.close();
			    } else {
					Files.write(Paths.get(fullpath), ("\n"+msg2).getBytes(), StandardOpenOption.APPEND);
			    }
			} catch( IOException e) {
				System.out.println("error in writing log file :"+ e);
			}
			*/
		} 
	}
	
	void debug(String msg) {
		if (chkval) {
			String msg2 = "D - " + getDateTime() + " " + getCaller() + " " + Userid + " - " + msg;
			 
			if(getCaller().indexOf("msg_jsp") < 0  ) { // && getCaller().indexOf("index_jsp") < 0 
				System.out.println(msg2);
			    /*
				String dir = "D:\\ONLINEADMIN\\bin\\tomcat9_awe\\logs\\"; //C:\ONLINEADMIN\bin\tomcat9_awe\logs
				String dt = getDate();
				String fnm = "awelogger."+dt+".txt"; 
				String fullpath = dir + fnm;
				
				try {
					File newpath = new File(dir);
				    if (!newpath.exists()) {
				    	newpath.mkdirs();
				    }
				    File newfile = new File(fullpath);
				    if (!newfile.exists()) {
				    	newfile.createNewFile();
				    	Writer fw = null;
				    	fw = new OutputStreamWriter(new FileOutputStream(fullpath), StandardCharsets.UTF_8);
				    	fw.write(msg2); 
				    	fw.close();
				    } else {
						Files.write(Paths.get(fullpath), ("\n"+msg2).getBytes(), StandardOpenOption.APPEND);
				    }
				} catch( IOException e) {
					System.out.println("error in writing log file :"+ e);
				} 
				*/
			} 
    	}
	}
	
	String getDate() {
		String rtn = "2019-09-07";
		Calendar cal= Calendar.getInstance();
	    int year = cal.get(Calendar.YEAR);
	    int mon = cal.get(Calendar.MONTH) + 1;
	    int day = cal.get(Calendar.DAY_OF_MONTH);
	    int hour = cal.get(Calendar.HOUR);  //log파일명에 시간추가

	    rtn = year+"-";
	    if(mon < 10) rtn += "0"+mon+"-";
	    else rtn += mon+"-";
	    
	    if(day < 10) rtn += "0"+day;
	    else rtn += day;
	    
	    return rtn+hour; 		//log파일명에 시간추가
	}
	
	String getDateTime() {
		String rtn = "";
		Calendar cal= Calendar.getInstance();
	    int year = cal.get(Calendar.YEAR);
	    int mon = cal.get(Calendar.MONTH) + 1;
	    int day = cal.get(Calendar.DAY_OF_MONTH);
	    int hour = cal.get(Calendar.HOUR);
	    int min = cal.get(Calendar.MINUTE);
	    int sec = cal.get(Calendar.SECOND);

	    rtn = year+"-";
	    if(mon < 10) rtn += "0"+mon+"-";
	    else rtn += mon+"-";
	    
	    if(day < 10) rtn += "0"+day;
	    else rtn += day;
	    
	    rtn += " " + hour + ":" + min + ":" + sec;  
	    
	    return rtn; 		
	}
	
	String getCaller() { 
		String rtn = "";
		StackTraceElement[] ste = new Throwable().getStackTrace(); 
		for(StackTraceElement element : ste) { 
			if("_jspService".equals(element.getMethodName())) {
				rtn = element.getClassName() + "(" + element.getLineNumber() + " of " + element.getFileName() + ")\n";
				break;
			}
		}
		return rtn; 
	}
}
%>
<%!
public final static class UUID implements java.io.Serializable, Comparable<UUID> { 
    private static final long serialVersionUID = -4856846361193249489L; 
    private final long mostSigBits; 
    private final long leastSigBits; 
    private static volatile SecureRandom numberGenerator = null; 
    private UUID(byte[] data) {
        long msb = 0;
        long lsb = 0;
        assert data.length == 16 : "data must be 16 bytes in length";
        for (int i=0; i<8; i++)
            msb = (msb << 8) | (data[i] & 0xff);
        for (int i=8; i<16; i++)
            lsb = (lsb << 8) | (data[i] & 0xff);
        this.mostSigBits = msb;
        this.leastSigBits = lsb;
    } 
    public UUID(long mostSigBits, long leastSigBits) {
        this.mostSigBits = mostSigBits;
        this.leastSigBits = leastSigBits;
    } 
    public static UUID randomUUID() {
        SecureRandom ng = numberGenerator;
        if (ng == null) {
            numberGenerator = ng = new SecureRandom();
        }

        byte[] randomBytes = new byte[16];
        ng.nextBytes(randomBytes);
        randomBytes[6]  &= 0x0f;  /* clear version        */
        randomBytes[6]  |= 0x40;  /* set to version 4     */
        randomBytes[8]  &= 0x3f;  /* clear variant        */
        randomBytes[8]  |= 0x80;  /* set to IETF variant  */
        return new UUID(randomBytes);
    } 
    public UUID nameUUIDFromBytes(byte[] name) {
        MessageDigest md;
        try {
            md = MessageDigest.getInstance("MD5");
        } catch (NoSuchAlgorithmException nsae) {
            throw new InternalError("MD5 not supported");
        }
        byte[] md5Bytes = md.digest(name);
        md5Bytes[6]  &= 0x0f;  /* clear version        */
        md5Bytes[6]  |= 0x30;  /* set to version 3     */
        md5Bytes[8]  &= 0x3f;  /* clear variant        */
        md5Bytes[8]  |= 0x80;  /* set to IETF variant  */
        return new UUID(md5Bytes);
    } 
    public UUID fromString(String name) {
        String[] components = name.split("-");
        if (components.length != 5)
            throw new IllegalArgumentException("Invalid UUID string: "+name);
        for (int i=0; i<5; i++)
            components[i] = "0x"+components[i];

        long mostSigBits = Long.decode(components[0]).longValue();
        mostSigBits <<= 16;
        mostSigBits |= Long.decode(components[1]).longValue();
        mostSigBits <<= 16;
        mostSigBits |= Long.decode(components[2]).longValue();

        long leastSigBits = Long.decode(components[3]).longValue();
        leastSigBits <<= 48;
        leastSigBits |= Long.decode(components[4]).longValue();

        return new UUID(mostSigBits, leastSigBits);
    } 
    public long getLeastSignificantBits() {
        return leastSigBits;
    } 
    public long getMostSignificantBits() {
        return mostSigBits;
    } 
    public int version() {
        // Version is bits masked by 0x000000000000F000 in MS long
        return (int)((mostSigBits >> 12) & 0x0f);
    } 
    public int variant() {
        // This field is composed of a varying number of bits.
        // 0    -    -    Reserved for NCS backward compatibility
        // 1    0    -    The Leach-Salz variant (used by this class)
        // 1    1    0    Reserved, Microsoft backward compatibility
        // 1    1    1    Reserved for future definition.
        return (int) ((leastSigBits >>> (64 - (leastSigBits >>> 62)))
                      & (leastSigBits >> 63));
    } 
    public long timestamp() {
        if (version() != 1) {
            throw new UnsupportedOperationException("Not a time-based UUID");
        }

        return (mostSigBits & 0x0FFFL) << 48
             | ((mostSigBits >> 16) & 0x0FFFFL) << 32
             | mostSigBits >>> 32;
    } 
    public int clockSequence() {
        if (version() != 1) {
            throw new UnsupportedOperationException("Not a time-based UUID");
        }

        return (int)((leastSigBits & 0x3FFF000000000000L) >>> 48);
    } 
    public long node() {
        if (version() != 1) {
            throw new UnsupportedOperationException("Not a time-based UUID");
        }

        return leastSigBits & 0x0000FFFFFFFFFFFFL;
    } 
    public String toString() {
        return (digits(mostSigBits >> 32, 8) + "-" +
                digits(mostSigBits >> 16, 4) + "-" +
                digits(mostSigBits, 4) + "-" +
                digits(leastSigBits >> 48, 4) + "-" +
                digits(leastSigBits, 12));
    } 
    private String digits(long val, int digits) {
        long hi = 1L << (digits * 4);
        return Long.toHexString(hi | (val & (hi - 1))).substring(1);
    } 
    public int hashCode() {
        long hilo = mostSigBits ^ leastSigBits;
        return ((int)(hilo >> 32)) ^ (int) hilo;
    } 
    public boolean equals(Object obj) {
        if ((null == obj) || (obj.getClass() != UUID.class))
            return false;
        UUID id = (UUID)obj;
        return (mostSigBits == id.mostSigBits &&
                leastSigBits == id.leastSigBits);
    } 
    public int compareTo(UUID val) {
        // The ordering is intentionally set up so that the UUIDs
        // can simply be numerically compared as two numbers
        return (this.mostSigBits < val.mostSigBits ? -1 :
                (this.mostSigBits > val.mostSigBits ? 1 :
                 (this.leastSigBits < val.leastSigBits ? -1 :
                  (this.leastSigBits > val.leastSigBits ? 1 :
                   0))));
    }
}
%>        	