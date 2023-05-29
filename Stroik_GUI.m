function varargout = Stroik_GUI(varargin)
% Stroik_GUI MATLAB code for Stroik_GUI.fig
%      Stroik_GUI, by itself, creates a new Stroik_GUI or raises the existing
%      singleton*.
%
%      H = Stroik_GUI returns the handle to a new Stroik_GUI or the handle to
%      the existing singleton*.
%
%      Stroik_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in Stroik_GUI.M with the given input arguments.
%
%      Stroik_GUI('Property','Value',...) creates a new Stroik_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Stroik_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Stroik_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Stroik_GUI

% Last Modified by GUIDE v2.5 24-Feb-2017 23:07:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Stroik_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @Stroik_GUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Stroik_GUI is made visible.
function Stroik_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Stroik_GUI (see VARARGIN)

% Choose default command line output for Stroik_GUI
handles.output = hObject;
set(handles.oktawa, 'Value', 5);
handles.oktawa=5;
set(handles.dzwiek, 'Value', 10);
handles.dzwiek=10;
set(handles.precyzja, 'Value', 1)
handles.precyzja=1;
set(handles.wynik, 'String', ' ');
set(handles.f_szuk, 'String', ' ');
set(handles.f_znal, 'String', ' ');
handles.polaczono=0;



%parametry steruj¹ce
handles.f_stroju=440;               %czêstotliwoœæ drgañ w³asnych a1
handles.pianino=load('pianino_2602_2242.mat');        %plik z strojonymi strunami
handles.typ_stroju=1;               %0 - równomiernie temperowany 1 - rozci¹gniête oktawy


%paramtery nagrywania
handles.fs=44100;
handles.bits_per_sample=16;
handles.numer_urzadzenia=-1;        %-1 - domyœlne
handles.prog=2;                     %próg wykrywania sygna³u
handles.dlugosc_sredniej_pocz=0.5;  %czas poboru próbek do wyznaczenia t³a - wykrywanie sygna³u
handles.dlugosc_probki=0.5;         %czas poboru próbek do wykrywania sygna³u


%paramtetry CZT
handles.CZT_zakres=200;             %ile centow czêstotliwoœci ma byæ widzianych na CZT
handles.wzg_dokl_czt=5;             %ile razy dok³adnoœæ CZT ma byæ wiêksza od dok³adnoœci mechanicznego strojenia

%parametry sterowania
handles.wsp_prop=10;                %wspolczynnik skalowania kroków w zale¿noœci od delta f/f0   
handles.serial_port_nazwa='COM3';   %nazwa portu, do którego pod³¹czony jest stroik

%Uaktualnienie danych GUI
guidata(hObject, handles);

% UIWAIT makes Stroik_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Stroik_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Przycisk_ok.
function Przycisk_ok_Callback(hObject, eventdata, handles)
% hObject    handle to Przycisk_ok (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
oktawa=handles.oktawa;
dzwiek=handles.dzwiek;

czestotliwosci=handles.pianino.czestotliwosci;

if handles.typ_stroju
    numer_dzwieku=12*oktawa+dzwiek-21;
    handles.numer_dzwieku=numer_dzwieku;
    %wpisanie co porównujemy (jakie s¹ czêstotliwoœci za³o¿one)
    if numer_dzwieku<handles.pianino.numer_start_temper
        %strój w dó³
        %f0_gora->f1_dol;
        f0_zal=czestotliwosci(1, numer_dzwieku+12);
        zakres=1;
    elseif numer_dzwieku>handles.pianino.numer_stop_temper
        %strój w górê
        %f1_dol->f0_gora;
        f0_zal=czestotliwosci(2, numer_dzwieku-12);
        zakres=3;
    else
        %strój równomiernie temperowany
        %f0 jest zgodny z temperacj¹
        %f0_zal=handles.pianino.czestotliwosci(1, numer_dzwieku);
        f0_zal=handles.f_stroju * 2^((12*oktawa+dzwiek-21-49)/12);
        zakres=2;
    end;
else
%Wyznaczam paramtery do CZT
[f0_zal, f0_zakres,M0,A0,W0, dlugosc_nagrania, f0_tol]=zalozenia(oktawa,dzwiek,handles.fs,handles.f_stroju,handles.precyzja, handles.CZT_zakres, handles.wzg_dokl_czt);
end;

[f0_zakres,M0,A0,W0, dlugosc_nagrania, f0_tol]=zalozenia_stretched(f0_zal,handles.fs,handles.f_stroju,handles.precyzja, handles.CZT_zakres, handles.wzg_dokl_czt);


set(handles.f_szuk, 'String', num2str(f0_zal, '%.2f'));
%Nagrywanie próbki dŸwiêku, potrzebnej do wykrywania dŸwiêku
[~, x_temp_sr]=nagrywanie(handles.dlugosc_sredniej_pocz,handles.fs,handles.bits_per_sample,handles.numer_urzadzenia);

x_prog=x_temp_sr*handles.prog;
set(handles.wynik, 'String', 'Mo¿na rozpocz¹æ nagrywanie');

%Wykrywanie dŸwiêku
while (x_temp_sr < x_prog)
    [~, x_temp_sr]=nagrywanie(handles.dlugosc_probki,handles.fs,handles.bits_per_sample,handles.numer_urzadzenia);
end;
set(handles.wynik, 'String', 'Wykryto dŸwiêk');


while 1
    %nagrywanie dzwieku
    [x,~]=nagrywanie(dlugosc_nagrania,handles.fs,handles.bits_per_sample,handles.numer_urzadzenia);
    %nagrywanie(dlugosc_nagrania,fs,bits_per_sample_numer_urzadzenia);
    
    %okienkowanie oknem Hamminga
    okno=hamming(length(x));
    x=okno.*x;

    %Chrip Z-Transform - funkcja MATLAB
    XcztM=czt(x, M0, W0, A0);
    f0_max=max(abs(XcztM));         %wyznaczanie maksimum
    %wyznaczanie czêstotliwoœci, dla której pojawia siê maksimum widma
    for i=1:length(XcztM)
        if f0_max == abs(XcztM(i)) 
            f0_CZT=f0_zakres(i);
        end;
    end;
    set(handles.f_znal, 'String', num2str(f0_CZT, '%.2f'));

    %plotowanie CZT
    %figure
    XcztM=XcztM/f0_max; %normalizowanie CZT
    plot(f0_zakres, abs(XcztM(1:M0)), 'Red')
    xlabel('Czêstotliwoœæ [Hz]'); ylabel('Wartoœæ sygna³u'), title('Widmo czêstotliwoœciowe'), grid('on');
    line([f0_zal-f0_tol f0_zal-f0_tol], [0 1], 'Color', 'Green', 'LineWidth', 1);
    line([f0_zal+f0_tol f0_zal+f0_tol], [0 1], 'Color', 'Green', 'LineWidth', 1);
    %Wyznaczono czêstotliwoœæ podstawow¹ sygna³u f0_CZT
    %Sprawdzam jak siê ma ta czêstotliwoœæ do za³o¿onej

    f0_roznica=f0_zal-f0_CZT;


    if (abs(f0_roznica)<=f0_tol)
       set(handles.wynik, 'String', 'Struna jest nastrojona');
       %zapisywanie do tablicy z czêstotliwoœciami nastrojonymi
       
       if zakres==1
            
            czestotliwosc_2_temp=f0_CZT;
            
            %czestotliwosci(2, numer_dzwieku)=(f0_CZT+czestotliwosci(2, numer_dzwieku)*czestotliwosci(4, numer_dzwieku))/(czestotliwosci(4, numer_dzwieku)+1);
           
            %Chrip Z-Transform - funkcja MATLAB
            %wyznaczanie czêstotliwoœci podstawowej
            [f0_zakres,M0,A0,W0, ~, ~]=zalozenia_stretched(f0_zal/2,handles.fs,handles.f_stroju,handles.precyzja, handles.CZT_zakres, handles.wzg_dokl_czt);
            
            XcztM=czt(x, M0, W0, A0);
            f0_max=max(abs(XcztM));         %wyznaczanie maksimum
            %wyznaczanie czêstotliwoœci, dla której pojawia siê maksimum widma
            for i=1:length(XcztM)
                if f0_max == abs(XcztM(i)) 
                    f0_CZT=f0_zakres(i);
                end;
            end;   
            
            czestotliwosc_1_temp=f0_CZT;
            
            %czestotliwosci(1, numer_dzwieku)=(f0_CZT+czestotliwosci(1, numer_dzwieku)*czestotliwosci(4, numer_dzwieku))/(czestotliwosci(4, numer_dzwieku)+1);
            %czestotliwosci(4, numer_dzwieku)=czestotliwosci(4, numer_dzwieku)+1;
            
       elseif zakres>1
            
           %czestotliwosci(1, numer_dzwieku)=(f0_CZT+czestotliwosci(1, numer_dzwieku)*czestotliwosci(4, numer_dzwieku))/(czestotliwosci(4, numer_dzwieku)+1);
            czestotliwosc_1_temp=f0_CZT;
           
            %Chrip Z-Transform - funkcja MATLAB
            %wyznaczanie pierwszej harmonicznej
            [f0_zakres,M0,A0,W0, ~, ~]=zalozenia_stretched(f0_zal*2,handles.fs,handles.f_stroju,handles.precyzja, handles.CZT_zakres, handles.wzg_dokl_czt);
            
            XcztM=czt(x, M0, W0, A0);
            f0_max=max(abs(XcztM));         %wyznaczanie maksimum
            %wyznaczanie czêstotliwoœci, dla której pojawia siê maksimum widma
            for i=1:length(XcztM)
                if f0_max == abs(XcztM(i)) 
                    f0_CZT=f0_zakres(i);
                end;
            end;  
            
            czestotliwosc_2_temp=f0_CZT;
            %czestotliwosci(2, numer_dzwieku)=(f0_CZT+czestotliwosci(2, numer_dzwieku)*czestotliwosci(4, numer_dzwieku))/(czestotliwosci(4, numer_dzwieku)+1);
            %czestotliwosci(4, numer_dzwieku)=czestotliwosci(4, numer_dzwieku)+1;
           
        end;
        save('test.mat','czestotliwosci');
        handles.czestotliwosc_1_temp=czestotliwosc_1_temp;
        handles.czestotliwosc_2_temp=czestotliwosc_2_temp;
        handles.pianino.czestotliwosci=czestotliwosci;
        %set(handles.pianino.czestotliwosci, czestotliwosci);
        
        break;

    else
       %arduino - sprzê¿enie
       kroki=0;

       if (f0_roznica<0)
           kroki=128;
       end;
       kompensacja=f0_roznica/f0_CZT*handles.wsp_prop;
       if (abs(kompensacja)>100)
           kroki=kroki+100;
       else
        kroki=kroki+round(abs(kompensacja));
       end;

       if (handles.polaczono>0)
        fprintf(handles.serial_port, '%d\n', kroki);
       end;
       set(handles.wynik, 'String', 'Struna jest w trakcie strojenia');
       %pause(0.2);
    end;

end;
guidata(hObject, handles);





% --- Executes on selection change in oktawa.
function oktawa_Callback(hObject, eventdata, handles)
% hObject    handle to oktawa (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns oktawa contents as cell array
%        contents{get(hObject,'Value')} returns selected item from oktawa
oktawa=get(hObject,'Value');
handles.oktawa = oktawa;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function oktawa_CreateFcn(hObject, eventdata, handles)
% hObject    handle to oktawa (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in dzwiek.
function dzwiek_Callback(hObject, eventdata, handles)
% hObject    handle to dzwiek (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns dzwiek contents as cell array
%        contents{get(hObject,'Value')} returns selected item from dzwiek
dzwiek=get(hObject,'Value');
handles.dzwiek = dzwiek;
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function dzwiek_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dzwiek (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function precyzja_Callback(hObject, eventdata, handles)
% hObject    handle to precyzja (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of precyzja as text
%        str2double(get(hObject,'String')) returns contents of precyzja as a double
handles.precyzja  = str2double(get(hObject, 'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function precyzja_CreateFcn(hObject, eventdata, handles)
% hObject    handle to precyzja (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function f_szuk_Callback(hObject, eventdata, handles)
% hObject    handle to f_szuk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of f_szuk as text
%        str2double(get(hObject,'String')) returns contents of f_szuk as a double


% --- Executes during object creation, after setting all properties.
function f_szuk_CreateFcn(hObject, eventdata, handles)
% hObject    handle to f_szuk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function f_znal_Callback(hObject, eventdata, handles)
% hObject    handle to f_znal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of f_znal as text
%        str2double(get(hObject,'String')) returns contents of f_znal as a double


% --- Executes during object creation, after setting all properties.
function f_znal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to f_znal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function wynik_Callback(hObject, eventdata, handles)
% hObject    handle to wynik (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of wynik as text
%        str2double(get(hObject,'String')) returns contents of wynik as a double


% --- Executes during object creation, after setting all properties.
function wynik_CreateFcn(hObject, eventdata, handles)
% hObject    handle to wynik (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in polacz.
function polacz_Callback(hObject, eventdata, handles)
% hObject    handle to polacz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
s=polacz(handles.serial_port_nazwa);
handles.serial_port=s;
set(handles.czy_polaczono, 'String', 'Po³¹czono');
handles.polaczono=1;
guidata(hObject, handles);


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function czy_polaczono_Callback(hObject, eventdata, handles)
% hObject    handle to czy_polaczono (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of czy_polaczono as text
%        str2double(get(hObject,'String')) returns contents of czy_polaczono as a double


% --- Executes during object creation, after setting all properties.
function czy_polaczono_CreateFcn(hObject, eventdata, handles)
% hObject    handle to czy_polaczono (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double


% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit10 as text
%        str2double(get(hObject,'String')) returns contents of edit10 as a double


% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in zamknij.
function zamknij_Callback(hObject, eventdata, handles)
% hObject    handle to zamknij (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close();


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
if (handles.polaczono)
    fclose(handles.serial_port);
end;
delete(hObject);


% --- Executes on button press in zapisz_strune.
function zapisz_strune_Callback(hObject, eventdata, handles)
% hObject    handle to zapisz_strune (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

czestotliwosci=handles.pianino.czestotliwosci;
numer_dzwieku=handles.numer_dzwieku;
czestotliwosci(1, numer_dzwieku)=(handles.czestotliwosc_1_temp+czestotliwosci(1, numer_dzwieku)*czestotliwosci(4, numer_dzwieku))/(czestotliwosci(4, numer_dzwieku)+1);
czestotliwosci(2, numer_dzwieku)=(handles.czestotliwosc_2_temp+czestotliwosci(2, numer_dzwieku)*czestotliwosci(4, numer_dzwieku))/(czestotliwosci(4, numer_dzwieku)+1);
czestotliwosci(4, numer_dzwieku)=czestotliwosci(4, numer_dzwieku)+1;

handles.pianino.czestotliwosci=czestotliwosci;

save('test_zapis.mat','czestotliwosci');
load('test_zapis.mat')
guidata(hObject, handles);





