% Haerer, Bernhardt and Schulz (2016)
% "PRACTISE - Photo Rectification And ClassificaTIon SoftwarE (V.2.1)"
%
%   written by
%   Stefan Haerer (BOKU Vienna)
%   12/2015
%   contact: stefan.haerer@boku.ac.at
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Name:       Input_17112011_A
%   Purpose:    Input m-file of PRACTISE (Example configuration A) 
%   Comment:    Edit variables as needed, but leave the condition terms of 
%               the if-else-conditions untouched (see Manual).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% switches
%   viewshed (vs)
%       0=use existing viewshed (Arc/Info ASCII Grid)
%       1=generate viewshed (specified camera angles)
vs=1;
%   ground control points (GCPs) & optimisation (os)     
%       0=w/o GCPs & w/o DDS optimisation
%       1=w GCPs & w/o DDS optimisation
%       2=w GCPs & w DDS optimisation
%       3=w GCPs & w DDS optimisation (interactive mode)
os=3; 
%   classification (cs)
%       0=manual classification
%       1=automatic blue band classification
%       2=automatic blue band + pca classification
%       3=interactive mode (default: automatic blue band classification) 
cs=3;
%   remote sensing (rs)
%       0=remote sensing (satellite image) off
%       1=use unzipped (raw) Landsat satellite image
%       2=use existing NDSI map of satellite image (Arc/Info ASCII Grid)
rs=0;
%   remote sensing probability (rsps)
%       0=use binary values snow/no snow photo map
%       1=use probability values in snow/no snow photo map
rsps=0;
%   remote sensing mask (rsms)
%       0=w/o mask (e.g. for excluding clouds)
%       1=use binary mask (e.g. for excluding clouds, Arc/Info ASCII Grid)
%       2=use fmask map (e.g. for excluding clouds, cloud shadows and/or water)     
rsms=0;
%   image (is)
%       0=classify a single photo
%       1=classify all photos in a specific folder (or a single photo 
%         with automatically derived input files)
is=1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% files
%   as input:
%       DEM (Arc/Info ASCII Grid)
fin_demW='..\dem\dem_10m_noise.txt';
%       folder
fin_folder='..\17112011_configA\';
%       Photograph (RGB), viewshed and ground control points 
%           subfolder of fin_folder
fin_imfolder='slr_ufs\'; 
if is==1                                                                   %KEEP
%           photo file extension
    fin_imformat='.tif';
elseif is==0                                                               %KEEP
%           photo file name
    fin_image='XYZ.tif';
end
%       Viewshed (Arc/Info ASCII Grid, same header and projection as DEM)
%           input file (Arc/Info ASCII Grid, same header and projection as DEM)
if vs==0 && is==1                                                           %KEEP
%           viewshed file extension
    fin_vsformat='.view.asc';
elseif vs==0 && is==0                                                       %KEEP
%           viewshed file name
        fin_viewW='XYZ.view.asc';
end                                                                        %KEEP
%       Ground Control Points 
%           table (ASCII-file w headerline: 
%            POINT_X POINT_Y POINT_Z Pixel_col Pixel_row GCPname)
if os>0 && is==1                                                            %KEEP
%           GCPs file extension
    fin_gcpformat='.gcp.txt';    
elseif os>0 && is==0                                                        %KEEP
%           GCPs file name
        fin_gcpW='XYZ.gcp.txt';
end                                                                        %KEEP
%       Remote sensing image 
if rs>0                                                                    %KEEP
%           subfolder of fin_folder
    fin_satfolder='XYZ_landsat\';
%           subfolders of fin_satfolder
%               only unzipped raw Landsat data if  rs==1  or 
%               NDSI map (Arc/Info ASCII Grid) if rs==2 
    fin_satfolder_image='XYZ_data\';
    if rs==2                                                               %KEEP
        fin_satname_ndsi='XYZ_NDSI.asc';
    end                                                                    %KEEP
%               unzipped raw Landsat look image for visualisation  
    fin_satfolder_look='XYZ_look\'; % uncomment/comment in case
%       (cloud) mask
    if rsms>0                                                              %KEEP
%           subfolder of fin_satfolder
        fin_satfolder_mask='XYZ_mask\';
        if rsms==1                                                         %KEEP
%               input file (Arc/Info ASCII Grid, same projection as DEM)
%                   use in anaylsis (e.g. no cloud) = 0
%                   exclude in analysis (e.g. cloud) = 1
            fin_satname_mask='XYZ_MTLFmask.asc'; 
        end                                                                %KEEP
    end                                                                    %KEEP
end                                                                        %KEEP
%   as output:
if is==0                                                                   %KEEP
%       folder
    fout_folder='C:\output_XYZ\';
%       root name of output files (e.g. variables, viewshed, snow cover map, ...)
    f_name='XYZ';
end                                                                        %KEEP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Camera parameters
%   view position 
%       longitude and latitude [m]
cam(:,1)=[6.4929997e+05; 5.25335826e+06]; % altitude will be calculated!
%       buffer zone around camera location (no sight barriers)
if vs==1                                                                   %KEEP
    buffer_radius=250; % in  [m]    
end                                                                        %KEEP
%   target position (longitude and latitude [m])
cam(:,2)=[6.4874085e+05, 5.25277133e+06]; % altitude will be calculated!
%   offset height of viewpoint and targetpoint [m]
cam_off=[1.5, 0]; 
%   properties
%       roll angle of camera (from -90 to 90 [deg]) 
%           horizontal = 0
%           clockwise towards +90 
%           anti-clockwise towards -90
cam_rol=0; 
%       focal length of camera lens [m]
cam_foc=0.031;
%       camera sensor 
%           height [m]
cam_hei=0.0149; 
%           width [m]
cam_wid=0.0223; 
% Classification
if cs==0                                                                   %KEEP
%   Manual classification (snow)
%       rule 1: RGB pixel values greater or equal than the thresholds [R;G;B]
    thres_rgb=[127;127;127]; 
%       rule 2: maximum delta value (maximum to minimum RGB value) of a pixel 
    delta_rgb=10; 
elseif cs>0                                                                %KEEP
%   Automatic classification (snow)
%       blue pixel value greater or equal than the threshold
    thres_b_orig=127;                                                      %keep
%       size of the moving average window for the DN frequency histogram 
%           use odd numbers
    movavgwindow=5;                                                        %keep
    if cs>1
%       PCA-based classification (rock)        
%           blue pixel value smaller than the threshold
        thres_b_low=63;
    end
end                                                                        %KEEP
% Satellite image bounding box (extent), recording time and Fmask "exclude
% in analysis (e.g. cloud)"-code 
if rs>0                                                                    %KEEP
%   Bounding box (extent might be slightly larger as all pixel centres inside are used), 
%   uncomment/comment to activate one case EITHER 1), 2) OR 3) 
%       1) coordinates in the order N, E, S and W
    satBB=[5255000.5, 654000.5, 5250199.5, 648099.5]; % uncomment/comment in case
%       2) or use full extent ('full')
 %    satBB='full'; % uncomment/comment in case
%       3) or bounding box=max rectangle area of camera image + satBB    
 %    satBB=6000; % in metres % uncomment/comment in case
%   Recording time
%       of the photograph
    if is==0                                                               %KEEP
        time=struct('year', yyyy, ...
                    'month', mm, ...
                    'day', dd, ...
                    'hour', HH, ...
                    'min', MM, ...
                    'sec', 0, ...
                    'UTC', 0);
    end                                                                    %KEEP
%       of the satellite image
    if rs==2                                                               %KEEP
        satdatetime='yyyy-mm-dd HH:MM:SS';
    end                                                                    %KEEP
%   Satellite image mask 
%     if rsms==1: pixels not masked are zero or no data
    if rsms==2                                                             %KEEP
%     Fmask "exclude in analysis (e.g. cloud)"-code 
%       0 = clear land pixel
%       1 = clear water pixel
%       2 = cloud shadow
%       3 = snow
%       4 = cloud
%       255 = no observation
        satmask_code=[1,2,4];
    end                                                                    %KEEP
end                                                                        %KEEP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DDS parameters
if os>1                                                                    %KEEP
%   Seed parameters (X0) will be calculated using
%           viewpoint longitude [m]
%           viewpoint latitude [m] 
%           viewpoint cam_off in [m]
%           cam_rol in [deg]                        
%           targetpoint longitude [m]
%           targetpoint latitude [m]
%           targetpoint cam_off in [m]
%           focal length of the camera lens [m]
%           camera sensor height [m]
%           camera sensor width [m]
%   Upper boundary deviations (UBD) from X0 using 
    UBD=[50, 50, 50, 3, 100, 100, 0, 0.0025, 0, 0];
%   Lower boundary deviations (LBD) from X0 using
    LBD=[-50, -50, -50, -3, -100, -100, 0, -0.0025, 0, 0];
%   run parameters    
%       Neighbourhood perturbation size (0.2 default by authors)
    DDS_R_os=0.2;                                                          %keep
%       Maximum number of function evaluations    
    DDS_MaxEval_os=3000;                                                   %keep
%   interactive mode
    if os==3                                                               %KEEP
%       maximum resulting value of a DDS optimisation before the
%       first interaction starts 
        gcpRMSE_optthres=1;
%       number of DDS optimisation tries until the criteria for the first 
%       interaction becomes more loose
        gcpRMSE_countthres=10;
    end                                                                    %KEEP
end                                                                        %KEEP
if rs>0                                                                    %KEEP
%   seed (theoretical range from -1 to 1)  
    NDSIthres0=0.4;
%   Upper boundary is the maximum NDSI value in the photographed area 
%   Lower boundary is the minimum NDSI value in the photographed area 
%   run parameters    
%       Neighbourhood perturbation size (0.2 default by authors)
    DDS_R_rs=0.2;                                                          %keep
%       Maximum number of function evaluations    
    DDS_MaxEval_rs=150;
end                                                                        %KEEP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% visualisation
%   marker size of figure: GCP optimisation 
if os>0
    os_MarkSiz=8;
end
%   marker size of figure: snow classification 
cs_MarkSiz=6;
%   marker size of figure: satellite snow cover map 
if rs>0
    rs_MarkSiz=6;
end