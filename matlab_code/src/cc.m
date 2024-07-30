function cc(borrarFig)
%cc elimina todo.

% Inputs
%   borrarFig       boolean, si false tncs no borra las figs.
%
% Ejemplo
%     = cc()
%Todo limpio, se�or!


%{
Laboratorio de Inteligencia y Visi�n Artificial
ESCUELA POLIT�CNICA NACIONAL
Quito - Ecuador

autor: z_tja
jonathan.a.zea@ieee.org
Cuando escrib� este c�digo, solo dios y yo sab�amos como funcionaba.
Ahora solo lo sabe dios.

29 January 2020
Matlab 9.5.0.944444 (R2018b).
%}
%
if nargin == 0
    borrarFig = false;
end

%%
if borrarFig
    close all
end

%%
evalin("base", 'clear all')
clearvars -global

%%
timerfindall
try
    stop(timerfindall)
    delete(timerfindall)
catch
end

%%
instrfindall
try
    fclose(instrfindall)
    delete(instrfindall)
catch
end


%%
fclose('all')

%%

%%
if nargin == 1
    if isequal(borrarFig, 'all')
        clc
    end
end
%%
drawnow
disp('Todo limpio, se�or!')
