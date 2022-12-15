clear
clc
format shortG
data = importdata('data.csv')
for i = 1:length(data.data(:,1))
   for j  = 2:length(data.data(1,:))
         data.data(i,j) = data.data(i,j)/data.data(i,1)*100
   end
end

csvwrite('normedValues.csv',data.data)