http://field-ii.dk/?examples/cfm_example/cfm_example.html
The routine field.m initializes the field system, and should be modified to point to the directory holding the Field II code and m-files. 
The routine make_sct.m is then called to make the file for the scatterers in the phantom. The script sim_flow.m is then called. Here the
 field simulation is performed and the data is stored in RF-files; one for each RF-line done. The script sim_flow.m is used for making the 
B-mode image as generated by tissue_pht.m. The images are then generated by the routines cfm_bmode.m and cfm_image.m.

