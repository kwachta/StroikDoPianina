clear

f_stroju=440;
nr_okt_start_temper=5;              %[1;9]
nr_dzw_start_temper=1;              %[1;12]
szer_strefy_temper=12;
nr_okt_2_w_chorze=2;          %a kontra 
nr_dzw_2_w_chorze=10;
nr_okt_3_w_chorze=3;         %c ma³a
nr_dzw_3_w_chorze=12;
plik_do_zapisu='pianino.mat';

czestotliwosci=zeros(4,82);
numer_start_temper=12*nr_okt_start_temper+nr_dzw_start_temper-21;
numer_stop_temper=numer_start_temper+szer_strefy_temper-1;

for i=numer_start_temper:numer_stop_temper
    czestotliwosci(1,i)=f_stroju * 2^((i-49)/12);
end;

nr_2_w_chorze=12*nr_okt_2_w_chorze+nr_dzw_2_w_chorze-21;
nr_3_w_chorze=12*nr_okt_3_w_chorze+nr_dzw_3_w_chorze-21;

czestotliwosci(3, 1:nr_2_w_chorze-1)=1;
czestotliwosci(3, nr_2_w_chorze:nr_3_w_chorze-1)=2;
czestotliwosci(3, nr_3_w_chorze:82)=3;

save(plik_do_zapisu, 'czestotliwosci', 'numer_start_temper', 'numer_stop_temper');
    
    
%f0_zal= f_stroju * 2^((12*nr_okt+nr_dzw-70)/12);



