path = 'F:\PP_MPSM\美股数据_ppmpsm\';%打开文件目录
path2 = [path '*.csv'];%打开文件目录下所有的csv文件
file_names = dir(path2);
assetData = []
column_name = []
for i = 1:length(file_names)
    file_name = file_names(i).name;
    mat_name = file_name(1:find(file_name == '历') - 1);%文件名
    file_name = [path file_name];
    file_data =  readmatrix(file_name);%读数据  
    close_data = file_data(:,2);%读收盘价
    close_data = flipud(close_data);%按时间升序重新排列数据
    assetData = [assetData, close_data]; %按不同股票的收盘价拼接在一起
    column_name = [column_name, string(mat_name)];
    column_name
save('assetData_ppmpsm.mat', 'assetData');%保存数据
end

