function [sygnal,srednia_sygnal]=nagrywanie(dlugosc_nagrania, fs, bits_per_sample, numer_urzadzenia)
%{ 
dlugosc_nagrania - d�ugo�� nagrania w [s]
fs - cz�stotliwo�� pr�bkowania 
bits_per_sample - ilo�� bit�w danych na pr�bk� sygna�u
numer_urz�dzenia - numer urz�dzenia nagrywaj�cego (domy�lne urz�dzenie nagrywaj�ce to -1)
sygnal - sygna� o zadanej d�ugo�ci
srednia_sygnal - �rednia warto�� sygna�u 
%}
%dlugosc_nagrania=2; 

    nagr=audiorecorder(fs, bits_per_sample, 1, numer_urzadzenia);
    %nagr=audiorecorder(44100,16,1,-1);
    recordblocking(nagr,dlugosc_nagrania);
    sygnal=getaudiodata(nagr);
    srednia_sygnal=mean(abs(sygnal));
end
