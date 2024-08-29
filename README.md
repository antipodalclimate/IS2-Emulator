# IS2-Emulator

First commit - code generates lines above the sea ice surface. This is used in Horvat et al (2024) and Buckley et al (2024)

Updated now for improved speed and physical realism. Code now draws from realistic orientations (azimuths) of IS2 RGTs overflying any scene. It uses a parameteric model for the IS2 flyover to generate segments in the image. Currently, segments are pixel-by-pixel. 

Data access: 

Classified image data come from Buckley et al (2020). See https://www.star.nesdis.noaa.gov/socd/lsa/SeaIce/SummerMeltClassification.php for data download and metadata. 

The ICESat-2 KMLs come from the IS2 tech specs website at https://icesat-2.gsfc.nasa.gov/science/specs . We only use the 2774 Arctic RGTs for the nominal mission orbits (Arctic Orbits --> Arctic_repeat1_GT7.kmz). 

To run this code

git clone https://github.com/antipodalclimate/IS2-Emulator

ln -s DATA_LOC Data/

matlab > run_emulator



 

