#pragma once

// taken from ulterius_def.h
enum Datatypes
{
    udtScreen           = 0x00000001,
    udtBPre             = 0x00000002,
    udtBPost            = 0x00000004,
    udtBPost32          = 0x00000008,
    udtRF               = 0x00000010,
    udtMPre             = 0x00000020,
    udtMPost            = 0x00000040,
    udtPWRF             = 0x00000080,
    udtPWSpectrum       = 0x00000100,
    udtColorRF          = 0x00000200,
    udtColorPost        = 0x00000400,
    udtColorSigma       = 0x00000800,
    udtColorVelocity    = 0x00001000
};

// taken from ulterius_def.h
class Data
{
public:
    /// data type - data types can also be determined by file extensions
    int type;
    /// number of frames in file
    int frames;
    /// width - number of vectors for raw data, image width for processed data
    int w;
    /// height - number of samples for raw data, image height for processed data
    int h;
    /// data sample size in bits
    int ss;
    /// roi - upper left (x)
    int ulx;
    /// roi - upper left (y)
    int uly;
    /// roi - upper right (x)
    int urx;
    /// roi - upper right (y)
    int ury;
    /// roi - bottom right (x)
    int brx;
    /// roi - bottom right (y)
    int bry;
    /// roi - bottom left (x)
    int blx;
    /// roi - bottom left (y)
    int bly;
    /// probe identifier - additional probe information can be found using this id
    int probe;
    /// transmit frequency
    int txf;
    /// sampling frequency
    int sf;
    /// data rate - frame rate or pulse repetition period in Doppler modes
    int dr;
    /// line density - can be used to calculate element spacing if pitch and native # elements is known
    int ld;
    /// extra information - ensemble for color RF
    int extra;
};
