% Example of scratch for DM problem
close all; clear all; clc;



% reading the initial data
% data example from: https://www.kaggle.com/c/house-prices-advanced-regression-techniques
T = readtable('train.csv');

% lets work with simple example
T = table( categorical(T.MSZoning) ,T.LotArea, T.YrSold, T.SalePrice, ... 
        'VariableNames', {'MSZoning', 'LotArea', 'YrSold', 'SalePrice'});

% some data visualization %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(1);  pie(T.MSZoning); 

% price dependencies on area
figure(3); grid on; hold on; 
plot(T.LotArea,T.SalePrice, '.b'); xlabel('LotArea'); ylabel('SalePrice'); %pause;

figure(4); grid on; hold on; title('By sale price')
plot(T.LotArea(ismember(T.YrSold, 2006)),T.SalePrice(ismember(T.YrSold, 2006)), '.b'); xlabel('LotArea'); ylabel('SalePrice');
plot(T.LotArea(ismember(T.YrSold, 2010)),T.SalePrice(ismember(T.YrSold, 2010)), '.r'); xlabel('LotArea'); ylabel('SalePrice');
legend('2006', '2010'); %pause;

figure(5); grid on; hold on;
plot(T.LotArea(ismember(T.MSZoning, {'RM'})),T.SalePrice(ismember(T.MSZoning, {'RM'})), '.b');  xlabel('LotArea'); ylabel('SalePrice');
plot(T.LotArea(ismember(T.MSZoning, {'FV'})),T.SalePrice(ismember(T.MSZoning, {'FV'})), '.r');  xlabel('LotArea'); ylabel('SalePrice');
legend('RM', 'FV'); %pause;

% end visualization %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% spliting data to train and test data
[n, m] = size(T);
dT = round(n * 0.6);



% creating DMM
dmm = DMM();
dmm = dmm.createModel(T(1:dT,1:end-1), T(1:dT , end));

dmm.plotDTree();


% loss represent model performance

trainingLoss = dmm.loss(T(1:dT,1:end-1), T(1:dT, end))
testLoss = dmm.loss(T(dT+1:n,1:end-1), T(dT+1:n, end))


% later we can use model to predict result of any data

dataToPredict = table( categorical({'RL'}) ,8450, 2010,    'VariableNames', {'MSZoning', 'LotArea', 'YrSold'});
predictedValue = dmm.predict(dataToPredict,1)


actualValues = [];
predictedValues = [];
for i = dT+1:n
    actualValues = [actualValues,   T(i, end).SalePrice ];
    predictedValues = [predictedValues, dmm.predict(T(i,1:end-1),1) ];
end


figure(55);
hold on;
grid on; 
plot(1:100, actualValues(1:100), 'LineWidth', 2);
plot(1:100, predictedValues(1:100), 'LineWidth', 2);
legend({'Actual values of Test DS','Predicted values of Test DS'},'FontSize',12,'FontWeight','bold');
xlabel('Instance Number','FontSize',14); ylabel('Price','FontSize',12,'FontWeight','bold');


