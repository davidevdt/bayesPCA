#ifndef AUX_FUNCTIONS_H
#define AUX_FUNCTIONS_H

double gammaFunc( double x, bool logScale ); 
double diGammaFunc( double x ); 
double betaFunc( double a, double b, bool logScale ); 

 
arma::mat invSMW( arma::mat D, arma::mat X, int I ); 

void funcX( arma::mat X, arma::mat &XTX, double &trXTX ); 


double gamd( double x, double logx, double a, double b ); 
double invgamd( double invx, double logx, double a, double b ); 
double gamh( double a, double b ); 
double invgamh( double a, double b ); 


arma::mat retHPDI( arma::vec mu, arma::vec sigma, double qz, int J ); 

void updateIncProbs( arma::mat &incProbs, int J, int D, arma::vec logpg, 
                     arma::vec logpinvg, arma::mat W2, double v0, 
                     arma::mat invTau, double invSigma2 ); 

arma::mat fMat( bool globalvar, std::string priorvar, arma::mat W2, double invsigma, bool SVS,
                arma::mat incProbs, double v0, arma::vec gammatau, arma::vec betatau, 
                arma::mat deltataupost, std::string hypertype, 
                int J, int D, arma::vec alphatau, int JD ); 
arma::mat logvarMat( bool globalvar, int J, int D, arma::mat f, std::string priorvar, 
                     arma::mat invTau, std::string hypertype, arma::vec alphatau ); 					 

#endif