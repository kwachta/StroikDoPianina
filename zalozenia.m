function [f0_zal, f0_zakres,M0,A0,W0, dlugosc_nagrania, f0_tol]=zalozenia(nr_okt, nr_dzw, fs, f_stroju, cent_precyzja, CZT_zakres, wzg_dokl_czt)

%wyznaczenie za³o¿onej czêstotliwoœci
f0_zal= f_stroju * 2^((12*nr_okt+nr_dzw-70)/12);

%Okreœlanie przedzia³u badanych czêstotliwoœci na podstawie zadanego dŸwiêku
fd0=f0_zal*2^(-CZT_zakres/1200);  
fg0=f0_zal*2^(CZT_zakres/1200);
%wyznaczanie wymaganej rozdzielczoœci CZT - wymagana dok³adnoœæ strojenia/dokl_czt
df0=f0_zal*(2^(cent_precyzja/1200)-1)/wzg_dokl_czt;

f0_zakres=fd0:df0:fg0;
M0=length(f0_zakres);                                %iloœæ punktów CZT
A0=exp(1i*2*pi*fd0/fs);
W0=exp(-1i*2*pi*((fg0-fd0)/(M0-1))/fs);

%Parametry nagrania
dlugosc_nagrania=10*round(M0/fs+0.01, 2);
f0_tol=f0_zal*(2^(cent_precyzja/1200)-1);

end