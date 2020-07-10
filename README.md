# ConfigMgrHealthReporting
ConfigMgr Client Health Reporting &amp; long term data (extension)


Version: 0.1.13 - 03/13/2019  

With the help of this expansion, the program "ConfigMgr client health" in the areas of evaluation and storage of the long-term data and reporting.  
Make sure that ConfigMgr client health is already installed.  
You can find the latest version of ConfigMgr Client Health ==> https://gallery.technet.microsoft.com/ConfigMgr-Client-Health-ccd00bd7
  
&nbsp;
&nbsp;
&nbsp;
&nbsp;

## Technet Summary  

The Technet platform is no longer active. That's why I moved my solution to Github.  
old Link technet ==> <https://gallery.technet.microsoft.com/ConfigMgr-Client-Health-71b1e982>  
new Link github  ==> <https://github.com/KlausBilger/ConfigMgrHealthReporting>  
  
&nbsp;
&nbsp;
  
## about me  

I live in Germany where I work as a Principal System Center Configuration Manager consultant.  
I have been working with SMS since 1998 and as a trainer since 1992. my main Focus is System Center, SQL,  
Reporting, OSD, Orchestrator and any Kind of automatization,  
Application / Tool Development with C#, VB, PowerShell, T-SQL, VBS.  
contact info klaus.bilger@c-s-l.biz  
  
&nbsp;
&nbsp;

## Description

The script version 0.1.13 requires the database version 0.8.2.
The complete documentation can be found on my website: https://c-s-l.biz/ConfigMgrClientHealthReporting

### Summary

In version 01.13, there are currently two reports. These two reports show all the necessary information through numerous filters and are very flexible and highly dynamic.  
With the help of the filters can be switched between current data and historical data. In each of the two-time window can be over a freely configurable filter   
the time window can be selected. As a standard, are in the current timeframe (1,3,5,7,30) days and in the long-term area (30, 45, 60, 90 ,120 ,180, 365) are predefined.

These filters are centrally located in the client health database and can be adapted at any time. Through the interactive link between the dashboard Report and the Client Data Report,  
the filter in the client report is automatically set to the desired function. Therefore, only the values that are necessary in the context shown.  
Both reports have a freely definable color set and are therefore adaptable to any customers CI.
  
&nbsp;
&nbsp;

### Dashboard Report  

With the help of the dashboard provides an overview of the entire state of clients that are managed with the help of ConfigMgr client health.  
The Client Dashboard has 3 sub-areas. In the first section (top left), the graphic "Health Summary" is displayed.  
In the right pane are the 3 tables dynamically via the SCCM agent through the SCCM agent version and on the monitored components (Columns for total, OK, error, fixed).

The "Client Information" table in the lower part of the reports shows a total overview of all clients based on the Windows OS.  
The table lists all the important columns, which provide an overview of the client version and the monitored components such as DNS, Services, BITS, WMI, and WUA Handler.

![Dashboard Report](https://github.com/KlausBilger/ConfigMgrHealthReporting/blob/master/Dashboard.jpg)

&nbsp;
&nbsp;
&nbsp;
  
### Report "Client Data"  

The second report "Client Data" shows data per system. This can be created dynamically via numerous filter the view almost flexible.  
Among other things, there is the possibility of using the filter "actual range" to select the current time or by a  
combination of "use long term data" and the "long term" long-term data. The columns you want to display,  
you can use the filter columns to show" can be set so that only the columns that are to be displayed, also visible.

About the Filter "colored output can be used to specify whether the table as shown below on a colored highlighting or not.
The Values for e.g. "Error" or "fixed" should be marked in color.

![Client Data Report](https://github.com/KlausBilger/ConfigMgrHealthReporting/blob/master/Clientdata.jpg)

&nbsp;
&nbsp;
&nbsp;
  
## Categorie

ConfigMgr, Configuration Manager, Center Configuration Manager, SCCM 2012, System Center 2012 Configuration Manager,
Distributions Server, Content Libary
  
&nbsp;
&nbsp;
&nbsp;

## CHANGE LOG
  
0.1.13 release (03/13/2019)
Update auf Version 0.1.13
add Component Link to dashboard,
bugfix SQL Statement for client data
  
0.1.11 release (11/08/2019)
bugfix Dashboard
-- Para_Use_Long_Term_Data =0
-- Report Field "non active" Tbl.

0.1.10 first public release (03/08/2019) 
  
&nbsp;
&nbsp;
&nbsp;

***  
**Plattformen Support:**
  
|OS name    |Support|
|---    |---  
|Windows 10 |Y  
|Windows Server 2012 R2 |Y  
|Windows Server 2008 R2 |Y  
|Windows Server 2008    |Y  
|Windows Server 2003    |Y  
|Windows Server 2016    |Y  
|Windows 8  |Y  
|Windows 7  |Y  
|Windows Vista  |Y  
|Windows XP  |Y  
|Windows 2000  |N  
  
&nbsp;
&nbsp;
&nbsp;
&nbsp;
&nbsp;
&nbsp;
&nbsp;
&nbsp;

**Rev Info**
last update 10.07.2020 (v 0.1.13)  

eof  

