function varargout = Recording_Data(varargin)
% RECORDING_DATA M-file for Recording_Data.fig
%      RECORDING_DATA, by itself, creates a new RECORDING_DATA or raises the existing
%      singleton*.
%
%      H = RECORDING_DATA returns the handle to a new RECORDING_DATA or the handle to
%      the existing singleton*.
%
%      RECORDING_DATA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RECORDING_DATA.M with the given input arguments.
%
%      RECORDING_DATA('Property','Value',...) creates a new RECORDING_DATA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Recording_Data_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Recording_Data_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Recording_Data

% Last Modified by GUIDE v2.5 29-Jul-2008 10:22:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Recording_Data_OpeningFcn, ...
                   'gui_OutputFcn',  @Recording_Data_OutputFcn, ...
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


% --- Executes just before Recording_Data is made visible.
function Recording_Data_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Recording_Data (see VARARGIN)

% Choose default command line output for Recording_Data
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
set(handles.Motes_list, 'String', [ 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18]);
clist = comlist; 
set(handles.USB_ID, 'String', clist);
set(handles.Experiement, 'String', 99);
set(handles.Subject, 'String', 99);
set(handles.Movement, 'String', 99);
set(handles.Cameras, 'String', 1);
set(handles.Initialize,'Enable','on');
set(handles.Start_Recording,'Enable','off');
set(handles.Stop_Recording,'Enable','off');
% UIWAIT makes Recording_Data wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Recording_Data_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Start_Recording.
function Start_Recording_Callback(hObject, eventdata, handles)
% datadir='.\raw\';
dlg_ans = 'No';
Experiement_selected = str2num(get(handles.Experiement,'String'))
Subject_selected = str2num(get(handles.Subject,'String'))
Movements_selected = str2num(get(handles.Movement,'String'))
fname = sprintf('raw/m%04d_s%02d_m%02d.txt',Experiement_selected,Subject_selected,Movements_selected);
v11 = exist(fname,'file');
% v22 = strcmp(dlg_ans,'No');
if (exist(fname,'file')== 2)
dlg_ans = questdlg('Experiement already exist. Do you want to overwrite the data?')
    if strcmp(dlg_ans,'Yes')== 1
        fname1 = sprintf('m%04d_s%02d_m%02d',Experiement_selected,Subject_selected,Movements_selected)
        start_recording(fname1)
        set(handles.Start_Recording,'Enable','off');
        set(handles.Stop_Recording,'Enable','on');
    end
else
fname1 = sprintf('m%04d_s%02d_m%02d',Experiement_selected,Subject_selected,Movements_selected)
start_recording(fname1)
set(handles.Start_Recording,'Enable','off');
set(handles.Stop_Recording,'Enable','on');
end
% hObject    handle to Start_Recording (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in Stop_Recording.
function Stop_Recording_Callback(hObject, eventdata, handles)
stop_recording()
set(handles.Initialize,'Enable','off');
set(handles.Start_Recording,'Enable','on');
set(handles.Stop_Recording,'Enable','off');
% hObject    handle to Stop_Recording (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on selection change in Movements.
function Movements_Callback(hObject, eventdata, handles)
% hObject    handle to Movements (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns Movements contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Movements


% --- Executes during object creation, after setting all properties.
function Movements_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Movements (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in Motes_list.
function Motes_list_Callback(hObject, eventdata, handles)
index_selected = get(hObject,'Value');
% list = get(hObject,'String');
% item_selected = list{index_selected}; % Convert from cell array
% hObject    handle to Motes_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns Motes_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Motes_list


% --- Executes during object creation, after setting all properties.
function Motes_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Motes_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Cameras_Callback(hObject, eventdata, handles)
% hObject    handle to Cameras (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Cameras as text
%        str2double(get(hObject,'String')) returns contents of Cameras as a double


% --- Executes during object creation, after setting all properties.
function Cameras_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Cameras (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Initialize.
function Initialize_Callback(hObject, eventdata, handles)
baud_rate = 115200;
packet_size = 41;
cache_size = 200;
index_selected = get(handles.Motes_list,'Value')
list = get(handles.Motes_list,'String')
Motes_selected = str2num(list(index_selected,:))
% list(index_selected,:)
% Cam_selected = get(handles.Cameras,'String')
Cam_selected = str2num(get(handles.Cameras,'String'))
Usb_index_selected = get(handles.USB_ID,'Value')
Usb_list = get(handles.USB_ID,'String')
Usb_Port_selected = Usb_list{Usb_index_selected,:}
%disp('fixing to setup');
setup(Cam_selected,Motes_selected,Usb_Port_selected,baud_rate,packet_size,cache_size);    
%disp('done setting up');
set(handles.Initialize,'Enable','off');
set(handles.Start_Recording,'Enable','on');
set(handles.Stop_Recording,'Enable','off');


% hObject    handle to Initialize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function Experiement_Callback(hObject, eventdata, handles)
% hObject    handle to Experiement (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Experiement as text
%        str2double(get(hObject,'String')) returns contents of Experiement as a double


% --- Executes during object creation, after setting all properties.
function Experiement_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Experiement (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Subject_Callback(hObject, eventdata, handles)
% hObject    handle to Subject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Subject as text
%        str2double(get(hObject,'String')) returns contents of Subject as a double


% --- Executes during object creation, after setting all properties.
function Subject_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Subject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Movement_Callback(hObject, eventdata, handles)
% hObject    handle to Movement (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Movement as text
%        str2double(get(hObject,'String')) returns contents of Movement as a double


% --- Executes during object creation, after setting all properties.
function Movement_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Movement (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function USB_ID_Callback(hObject, eventdata, handles)
% hObject    handle to USB_ID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of USB_ID as text
%        str2double(get(hObject,'String')) returns contents of USB_ID as a double


% --- Executes during object creation, after setting all properties.
function USB_ID_CreateFcn(hObject, eventdata, handles)
% hObject    handle to USB_ID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


