%% Number of ensemble faces
function [Group1Rect,Group2Rect] = Parameters_Input()
%This is the function for typing in the number of faces in ensemble
%conditions. It has been incorporated into the main function

num_lines = 1;
Num_Face = {'Number of Faces for Ensemble Display Group 1'};
dlg_title = 'Parameter 1A';
NF_input = inputdlg(Num_Face,dlg_title,num_lines);
DG_1_NUM = str2double(cell2mat(NF_input));
if ~(DG_1_NUM == 2 || DG_1_NUM == 3 ||DG_1_NUM == 4)
    error('Number of Display Locations is not correct.');
end

switch DG_1_NUM
    case 2
        DG_1 = {'Rect number 1 for Display Group 1','Rect number 2 for Display Group 1'};
    case 3
        DG_1 = {'Rect number 1 for Display Group 1','Rect number 2 for Display Group 1','Rect number 3 for Display Group 1'};
    case 4
        DG_1 = {'Rect number 1 for Display Group 1','Rect number 2 for Display Group 1',...
            'Rect number 3 for Display Group 1','Rect number 4 for Display Group 1'};
end

dlg_title = 'Parameter 1B';
DG_1_input  = inputdlg(DG_1,dlg_title,num_lines);
DG_1_Rect = str2num(cell2mat(DG_1_input));
Group1Rect = DG_1_Rect';

Num_Face = {'Number of Faces for Ensemble Display Group 2'};
dlg_title = 'Parameter 2A';
NF_input = inputdlg(Num_Face,dlg_title,num_lines);
DG_2_NUM = str2double(cell2mat(NF_input));
if ~(DG_2_NUM == 2 || DG_2_NUM == 3 ||DG_2_NUM == 4)
    error('Number of Display Locations is not correct.');
end

switch DG_2_NUM
    case 2
        DG_2 = {'Rect number 1 for Display Group 2','Rect number 2 for Display Group 2'};
    case 3
        DG_2 = {'Rect number 1 for Display Group 2','Rect number 2 for Display Group 2','Rect number 3 for Display Group 2'};
    case 4
        DG_2 = {'Rect number 1 for Display Group 2','Rect number 2 for Display Group 2',...
            'Rect number 3 for Display Group 2','Rect number 4 for Display Group 2'};
end

dlg_title = 'Parameter 1B';
DG_2_input  = inputdlg(DG_2,dlg_title,num_lines);
DG_2_Rect = str2num(cell2mat(DG_2_input));
Group2Rect = DG_2_Rect';

