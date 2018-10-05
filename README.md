# Probability Distribution Function (PDF) 
The Probability Distribution Function (PDF) model predicts the solar wind speed 5 days in advance.

## Prerequisites 
* IDL

## Installing
No step is required to install other than downloading the project.

## Running

To run PDF: 
```
./pdf.sh YYYYMMDDHH1111
```
where YYYY, MM, DD, and HH represent the year, month, day, and hour of the start of the predictions.
For example: 
```
./pdf.sh 20170808021111
```
will run PDF to predict the solar wind speed from August 8 to August 13, 2017.
The 1111 characters are options that you can edit to change the format of the output.

## Authors
* Charles D. Bussy-Virat
* Aaron J. Ridley

## License
This project is licensed under the Apache License v2.0 - see the LICENSE file for details.

## Acknowledgments
This project was funded by Air Force Office of Scientific Research grant FA9550-12-1-0265. We acknowledge use of NASA/GSFC’s Space Physics Data Facility’s OMNIWeb service and OMNI data.

## Contact
If you have any questions, please email me at cbv@umich.edu.
