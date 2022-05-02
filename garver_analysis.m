clc;clear;close all

%% read excel and initialize data

filename = 'Garver_data.xlsx';
busdata_matrix = xlsread(filename, 'Busdata');
linedata_matrix = xlsread(filename, 'Linedata');
linedata = linedata_matrix;
busdata = busdata_matrix;
%% load growth calculation
load_growth = [0 50 116.5];
% load_growth=[0 100];
for numcase = 1:length(load_growth)
    linedata = linedata_matrix;
    busdata = busdata_matrix;
    busdata(:,4) = busdata(:,4) * (1 + load_growth(numcase) / 100); %in percentages for example 50 if load grows 50%
    %     busdata(:,4)=busdata(:,4)+(load_growth(numcase)/100);
    %% lines status 1:line in // 0:line out
    line_status = ones( length( linedata(:, 1) ), 1);
    linedata(:, 7) = line_status;
    %% call rundcpf function and run dc power flow
    [P_line] = rundcpf(busdata, linedata);
    P_table=P_line;
    %% Condition study
    numline = length(linedata(:, 1));
    for i = 1:numline
        linedata(i, 7)=0;
        [P_line] = rundcpf(busdata, linedata);
        if i == 1
            P_line=[0, P_line];
        else
            P_line=[P_line(1:i-1), 0, P_line(i:end)];
        end
        P_table(i+1, :)=P_line;
        linedata(i, 7)=1;
    end
    %% print conclusion
    Condition_situation=["Normal";"1-2";"1-4";"1-5";"2-3";"2-4";"3-5"];
    Condition_situation2=["-";"1-2";"1-4";"1-5";"2-3";"2-4";"3-5"];
    fprintf( '\n');
    fprintf( '\n===================================================================================');
    str=append('\n*** Garver grid - Normal and N-1 Conditions Study ---> ',...
        'load Growth = ',num2str(load_growth(numcase)),' ***');
    fprintf( str);
    fprintf( '\n-----------------------------------------------------------------------');
    fprintf( '\n %7.7s%10.4s%10.4s%10.4s%10.4s%10.4s%10.4s',Condition_situation2');
    fprintf( '\n %7.7s%10.4f%10.4f%10.4f%10.4f%10.4f%10.4f',[Condition_situation P_table]');
    fprintf( '\n-----------------------------------------------------------------------');
    %%
    Condition_situation3 = ["Normal";"1-2";"1-4";"1-5";"2-3";"2-4";"3-5";"condition"];
    for i = 1:size(P_table, 1)
        cap = abs(P_table(i, :)');
        delta_p_cap = linedata(:, 6) < cap;
        if i == 1
            sentence = '';
        else
            sentence = "outage of line ";
        end
        str = append('\n\nOverloaded line(s) in ', sentence, Condition_situation3(i), ' condition: ');
        fprintf(str);
        for j = 1:size(delta_p_cap, 1)
            if delta_p_cap(j) == 1
                P_overload = linedata(:, 6) - cap;
                str = append( Condition_situation3(j+1), ' --> ', '(', num2str( abs( P_overload(j) ) ), ' MW)');
                fprintf( '\n');
                fprintf(str);
            end
        end
    end
end

fprintf('\n');
