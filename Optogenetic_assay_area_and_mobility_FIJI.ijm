
run("Set Measurements...", "area mean standard modal min centroid center perimeter bounding fit shape feret's integrated median skewness area_fraction display redirect=None decimal=3");

  title = "Intensity Sholl";
  types = newArray("1-cropping & trimming videos", "2-Fast stabilizing macro", "3-Automatic detection of larva and measuring changes in larval area & mobiliy");
  Dialog.create("Optogenetic video processing");
  Dialog.addChoice("Type:", types);

  Dialog.show();

  type = Dialog.getChoice();

print(type);

 if(type=="1-cropping & trimming videos")
  {

  	  Dialog.create("Instructions for cropping & trimming videos");
  Dialog.addMessage("Select a folder that contains '.avi' files. \nThis macro trims the video keeping only 180-780 frames and crops the video down to 1342 by 778 (pixels W,H). \n NOTE: You can change the dimensions for trimming in line 69 and for cropping in line 72. ", 14);
  Dialog.show;







   requires("1.33s"); 
   dir = getDirectory("Choose a folder containing only avi files ");
   setBatchMode(true);
   count = 0;
   countFiles(dir);
   n = 0;
   processFiles(dir);
   //print(count+" files processed");
   
   function countFiles(dir) {
      list = getFileList(dir);
      for (i=0; i<list.length; i++) {
          if (endsWith(list[i], "/"))
              countFiles(""+dir+list[i]);
          else
              count++;
      }
  }

   function processFiles(dir) {
      list = getFileList(dir);
      for (i=0; i<list.length; i++) {
          if (endsWith(list[i], "/"))
              processFiles(""+dir+list[i]);
          else {
             showProgress(n++, count);
             path = dir+list[i];
             processFile(path);
          }
      }}
  

  function processFile(path) {
       
           open(path);
               
run("Slice Keeper", "first=180 last=780 increment=1");


makeRectangle(244, 302, 1342, 778);

run("Crop");
		   saveAs("Avi", path);
        
   
	close();

		  close();

  }
  print("Macro finished");





close("Log");
close("Results");

  }


  if(type=="2-Fast stabilizing macro")
  {
  	print("no");
  	  Dialog.create("Fast stabilizing macro");
  Dialog.addMessage("This macro is used for stabilizing Drosophila larval videos in the XY-plane. \n Select the same folder as the First step. \n", 14);
  Dialog.show;


run("Set Measurements...", "area mean standard modal min centroid center perimeter bounding fit shape feret's integrated median skewness area_fraction stack display redirect=None decimal=3");
dir_avi=getDirectory("Choose a folder containing only trimmed & cropped videos"); 


list = getFileList(dir_avi );
for (cc=0; cc<list.length; cc++) 
{
	open( dir_avi + list[cc] );
run("8-bit");
dem=getTitle();
num_frames=nSlices();
print(dem);
 rename("mine");
	selectWindow("mine");
run("Canvas Size...", "width=2000 height=1200 position=Center zero");
	run("Duplicate...", "duplicate");


selectWindow("mine-1");


setThreshold(40, 255);
setOption("BlackBackground", false);
run("Convert to Mask", "method=Default background=Light");

run("Erode", "stack");
run("Erode", "stack");
run("Remove Outliers...", "radius=2 threshold=50 which=Dark stack");
run("Dilate", "stack");

run("Z Project...", "projection=[Max Intensity]");
run("Analyze Particles...", "size=1500-Infinity display");

Table.sort("Area");
resultcount=nResults()-1;
xcor=getResult("BX",resultcount)-200;
ycor=getResult("BY",resultcount)-200;
recwid=getResult("Width",resultcount)+400;
recleg=getResult("Height",resultcount)+400;
close();
close();

makeRectangle(xcor, ycor, recwid, recleg);
run("Crop");
run("Clear Results");
selectWindow("mine");

run("Duplicate...", "duplicate");





setThreshold(40, 255);
setOption("BlackBackground", false);
run("Convert to Mask", "method=Default background=Light");

run("Erode", "stack");
run("Erode", "stack");
run("Remove Outliers...", "radius=2 threshold=50 which=Dark stack");
run("Dilate", "stack");

run("Analyze Particles...", "size=1000-Infinity display stack");


selectWindow("mine-1");
run("Close");
for (xx=0; xx<num_frames; xx++) {
	yt=xx+1;
	//yname=dem + xx +1;
	//run("8-bit");

Mex2=getResult("XM",0)-getResult("XM",xx);
Mey2=getResult("YM",0)-getResult("YM",xx); 	 
selectWindow("mine");
setSlice(getResult("Slice",xx));
run("Translate...", "x=Mex2  y=Mey2 interpolation=None slice");

}
Mex3=getResult("XM",0);
Mey3=getResult("YM",0); 	 
makeRectangle(Mex3-175, Mey3-175, 350, 350);
run("Crop");
Stack.setFrameRate(30)
saveAs("Avi", dir_avi + dem);
run("Close");
run("Clear Results");
}



close("Log");
close("Results");

  }

  if(type=="3-Automatic detection of larva and measuring changes in larval area & mobiliy")
  {
  	print("no");
  	  Dialog.create("Instructions for automatic detection of larva and measuring changes in larval area & mobiliy");
  Dialog.addMessage("This macro is used for automatically detecting Drosophila larvae and measuring larval area & mobility. \n Select the same folder as the First and Second step. \n \nData (area, aspect ratio, and mobility) are stored in the same location as input folder. \n \nAdditionally, maximum intensity projection images for each video are stored. \nThis allows for post-hoc quality control, where one can assess proper XY stabilization.\nIf videos do not pass quality control, perform XY stabilization again.", 14);
  Dialog.show;



dir_avi=getDirectory("Choose a Directory"); 
list = getFileList(dir_avi );
for (cc=0; cc<list.length; cc++) 
{
open( dir_avi + list[cc] );
run("Z Project...", "projection=[Max Intensity]");


 ro_jpg=replace(list[cc],".avi","Max.jpg");
saveAs("Jpeg", dir_avi+ ro_jpg);
close();



  
 Table.create("Results-1");

 for (xx=0; xx<nSlices; xx++) {
        data = xx;
        Table.set("Slice", xx, data);
     }



run("Duplicate...", "duplicate");

setOption("BlackBackground", false);
run("Convert to Mask", "method=Huang background=Dark");
run("Analyze Particles...", "size=1000-Infinity show=Masks display stack");
rename("masked");
	
for (i = 0; i < nResults; i++) {

//namee=list[cc];
namee=replace(list[cc],".avi","");


	areA=getResult("Area", i);
	aspe=getResult("AR", i);
	
Table.set("Name", (i), namee);
Table.set("Area_raw", (i), areA);
Table.set("Aspect Ratio_Maj_Min", (i), (aspe));

}

close("Results");
selectWindow("masked");
run("Duplicate...", "duplicate range=1-600");
rename("before");
selectWindow("masked");
run("Duplicate...", "duplicate range=2-601");
rename("after");
imageCalculator("Subtract create stack", "after","before");


run("Analyze Particles...", "size=0-Infinity display summarize stack");
Table.rename("Summary of Result of after", "Results");




selectWindow("Results-1");
for (i = 1; i < nResults; i++) {



	Mobi=getResult("Total Area", i);

	
Table.set("Mobility", (i), Mobi);

}
close("Results");


selectWindow("Results-1");

Table.rename("Results-1", "Results");
 ro_log=replace(list[cc],".avi","_data.csv");

	saveAs("Results", dir_avi+ ro_log);
	close("before");
	close("after");
	close("masked");
	close("Result of after");
	close("Results");
	close(list[cc]);
	close();
}



close("Log");
close("Results");
  }