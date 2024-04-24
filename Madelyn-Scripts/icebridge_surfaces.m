
surfaces = zeros(2500,2500,30);

% h5IceBridge folder has the raw data files and h5toIce, a function to quickly convert data into a binary double
% this just turns it all into one nice double
fileloc = './h5IceBridge/';

surf1 = h5read([fileloc '00136_20170717_classification.h5'],'/classification/');
    surfaces(:,:,1) = h5toIce(surf1,3501,6000,2751,5250); % SIC = 95.04, 20 border
surf8 = h5read([fileloc '00214_20170717_classification.h5'],'/classification/');
    surfaces(:,:,2) = h5toIce(surf8,2451,4950,1601,4100); % SIC = 93.60, 16 border
surf2 = h5read([fileloc '00216_20170717_classification.h5'],'/classification/');
    surfaces(:,:,3) = h5toIce(surf2,1601,4100,3501,6000); % SIC = 94.49, 4 border
surf18 = h5read([fileloc '00232_20170717_classification.h5'],'/classification/');
    surfaces(:,:,4) = h5toIce(surf18,2001,4500,2961,5460); % SIC = 91.70, 17 border
surf21 = h5read([fileloc '00235_20170717_classification.h5'],'/classification/');
    surfaces(:,:,5) = h5toIce(surf21,1501,4000,3501,6000); % SIC = 93.91, 31 border
surf25 = h5read([fileloc '00239_20170717_classification.h5'],'/classification/');
    surfaces(:,:,6) = h5toIce(surf25,2501,5000,2001,4500); % SIC = 96.40, 19 border COOL ONE
surf26 = h5read([fileloc '00240_20170717_classification.h5'],'/classification/');
    surfaces(:,:,7) = h5toIce(surf26,2301,4800,2466,4965); % SIC = 93.29, 35 border
surf27 = h5read([fileloc '00241_20170717_classification.h5'],'/classification/');
    surfaces(:,:,8) = h5toIce(surf27,1751,4250,2751,5250); % SIC = 93.42, 3 border
surf6 = h5read([fileloc '00248_20170717_classification.h5'],'/classification/');
    surfaces(:,:,9) = h5toIce(surf6,2201,4700,2201,4700); % SIC = 92.64, 77 border
surf14 = h5read([fileloc '00256_20170717_classification.h5'],'/classification/');
    surfaces(:,:,10) = h5toIce(surf14,1501,4000,3251,5750); % SIC = 93.22, 289 border
surf15 = h5read([fileloc '00257_20170717_classification.h5'],'/classification/');
    surfaces(:,:,11) = h5toIce(surf15,1501,4000,3501,6000); % SIC = 94.41, 189 border
surf17 = h5read([fileloc '00259_20170717_classification.h5'],'/classification/');
    surfaces(:,:,12) = h5toIce(surf17,2001,4500,3001,5500); % SIC = 94.52, 54 border
surf18 = h5read([fileloc '00260_20170717_classification.h5'],'/classification/');
    surfaces(:,:,13) = h5toIce(surf18,2201,4700,2001,4500); % SIC = 94.50, 59 border
surf20 = h5read([fileloc '00360_20170717_classification.h5'],'/classification/');
    surfaces(:,:,14) = h5toIce(surf20,1751,4250,3501,6000); % SIC = 94.99, 0 border
surf1 = h5read([fileloc '00361_20170717_classification.h5'],'/classification/');
    surfaces(:,:,15) = h5toIce(surf1,2476,4975,2606,5105); % SIC = 96.10, 0 border
surf5 = h5read([fileloc '00365_20170717_classification.h5'],'/classification/');
    surfaces(:,:,16) = h5toIce(surf5,2001,4500,3001,5500); % SIC = 94.64, 0 border
surf7 = h5read([fileloc '00367_20170717_classification.h5'],'/classification/');
    surfaces(:,:,17) = h5toIce(surf7,1751,4250,3401,5900); % SIC = 95.34, 0 border
surf8 = h5read([fileloc '00368_20170717_classification.h5'],'/classification/');
    surfaces(:,:,18) = h5toIce(surf8,2501,5000,2501,5000); % SIC = 94.17, 0 border
surf9 = h5read([fileloc '00369_20170717_classification.h5'],'/classification/');
    surfaces(:,:,19) = h5toIce(surf9,2151,4650,3001,5500); % SIC = 94.57, 0 border
surf10 = h5read([fileloc '00370_20170717_classification.h5'],'/classification/');
    surfaces(:,:,20) = h5toIce(surf10,2451,4950,2646,5145); % SIC = 94.51, 0 border
surf13 = h5read([fileloc '00373_20170717_classification.h5'],'/classification/');
    surfaces(:,:,21) = h5toIce(surf13,1356,3855,3501,6000); % SIC = 94.69, 0 border
surf20 = h5read([fileloc '00388_20170717_classification.h5'],'/classification/');
    surfaces(:,:,22) = h5toIce(surf20,1851,4350,3001,5500); % SIC =  95.15, 0 border
surf5 = h5read([fileloc '00393_20170717_classification.h5'],'/classification/');
    surfaces(:,:,23) = h5toIce(surf5,2501,5000,1851,4350); % SIC = 94.90, 287 border
surf6 = h5read([fileloc '00394_20170717_classification.h5'],'/classification/'); 
    surfaces(:,:,24) = h5toIce(surf6,2001,4500,2601,5100); % SIC = 95.08, 152 border
surf9 = h5read([fileloc '00397_20170717_classification.h5'],'/classification/');
    surfaces(:,:,25) = h5toIce(surf9,2001,4500,2801,5300); % SIC = 94.22, 281 border
surf10 = h5read([fileloc '00398_20170717_classification.h5'],'/classification/');
    surfaces(:,:,26) = h5toIce(surf10,2001,4500,2461,4960); % SIC = 95.27, 17 border
surf11 = h5read([fileloc '00399_20170717_classification.h5'],'/classification/');
    surfaces(:,:,27) = h5toIce(surf11,2151,4650,2501,5000); % SIC = 94.26, 11 border
surf12 = h5read([fileloc '00400_20170717_classification.h5'],'/classification/');
    surfaces(:,:,28) = h5toIce(surf12,2301,4800,2401,4900); % SIC = 95.25, 15 border
surf13 = h5read([fileloc '00401_20170717_classification.h5'],'/classification/');
    surfaces(:,:,29) = h5toIce(surf13,2501,5000,2301,4800); % SIC = 95.34, 7 border
surf13 = h5read([fileloc '00402_20170717_classification.h5'],'/classification/');
    surfaces(:,:,30) = h5toIce(surf13,2501,5000,2301,4800); % SIC = 94.49, 17 border


trueSIC_real = zeros(1,30);
for j = 1:30;
    trueSIC_real(j) = sum(surfaces(:,:,j),'all') / 6250000;
end