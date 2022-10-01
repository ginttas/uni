% Decision Making Model
classdef DMM
   
    
   properties
      % data uploaded with model
      initialData
      initialTargetValues
      % TODO: define variables necessary for decision tree
        
      NodeParent % relations between node and parent
      Criterion % index of splitting criterion
      Comparison % 0 - "<"; 1 - ">=", 2 equals (for categorical),  3 not equals (for categorical)
      SplittingValue % threshold values
      TrueNode 
      FalseNode
      NodeValue % LeafNodeValues
      NodeLabel% Labels for visualization
      minParentNode = 100; % minimal number of samples in node to stop splitting
      maxNodeNr; % temporary variable to assign node numbers// stores maximum node number at the moment
   end
   
   methods
        
       
    % create model
    function obj = createModel(obj, data, target)
       obj.initialData = data;
       obj.initialTargetValues = target;
       obj.TrueNode = int32.empty(0,2);
       obj.FalseNode = int32.empty(0,2);
       obj.NodeValue = [];
       obj.NodeLabel = [];
       dataBranch = data; targetBranch = target; % for the root node
       obj.maxNodeNr = 1;
       [obj, nodes] = constructDecisionTree(obj,dataBranch, table2array(targetBranch), 1, '');

    end
    

    function val = predict(obj, instance, nodeNr)
        
        if (ismember(nodeNr,obj.NodeValue(:,1)))
            IS = obj.NodeValue(:,1)==nodeNr; 
            index = find(IS==1,1);
            val = obj.NodeValue(index,2);
            return;
        end
        IS = obj.Criterion(:,1)==nodeNr; 
        index = find(IS==1,1);
        val = obj.Criterion(index,2);
        splittingCriteriaInstance = table2array(instance(1,val));
       
       
        IS = obj.Comparison(:,1)==nodeNr; 
        index = find(IS==1,1);
        comparison = obj.Comparison(index,2);

        for i = 1:size(obj.SplittingValue,1)
            temp = obj.SplittingValue(i,:);
            if (temp{1} == nodeNr)
                splittingValue = temp{2};
                break;
            end
        end
        
       if(comparison == 0)
           if (splittingCriteriaInstance < splittingValue)
               IS = obj.TrueNode(:,1)==nodeNr; 
               index = find(IS==1,1);
               val = predict(obj, instance, obj.TrueNode(index,2));
           else
               IS = obj.FalseNode(:,1)==nodeNr; 
               index = find(IS==1,1);
               val = predict(obj, instance, obj.FalseNode(index,2));
           end
       elseif(comparison == 2)
           if (splittingCriteriaInstance == splittingValue)
               IS = obj.TrueNode(:,1)==nodeNr; 
               index = find(IS==1,1);
               val = predict(obj, instance, obj.TrueNode(index,2));
           else
               IS = obj.FalseNode(:,1)==nodeNr; 
               index = find(IS==1,1);
               val = predict(obj, instance, obj.FalseNode(index,2));
           end
       end      
    end

    % lets use MSE
    function err = loss(obj, testData, testTarget)
        err = 0;
        for i=1:height(testTarget)
            targetVal = testTarget(i, 1).Variables;
            prediction = obj.predict(testData(i,:),1);
            err = err + (targetVal - prediction)^2;
        end
        err = err / height(testTarget);
    end
    
    
    
    % construct decision tree
    function [obj, nodes] = constructDecisionTree(obj,dataBranch, targetBranch, nodeNr,label)
        % stopping criteria due to parent size
        if(size(targetBranch,1) <= obj.minParentNode)
%             obj.maxNodeNr = obj.maxNodeNr + 1;
            leafValue = mean(targetBranch);
            obj.NodeLabel = [obj.NodeLabel; nodeNr {sprintf('%s, %5.2f',label,leafValue)}];
            obj.NodeValue = [obj.NodeValue; nodeNr leafValue];
            nodes = nodeNr;
            return;
        end
        [criterion, comparison, splittingValue] = ...
           getCriterion(obj, dataBranch, targetBranch);
         % stopping criteria du to variance
        if(criterion == -1)
%             obj.maxNodeNr = obj.maxNodeNr + 1; 
            leafValue = mean(targetBranch);
            obj.NodeLabel = [obj.NodeLabel; nodeNr {sprintf('%s, %5.2f',label,leafValue)}];
            obj.NodeValue = [obj.NodeValue; nodeNr leafValue];
            nodes = nodeNr;
            return;
        end
       
       
       obj.Criterion = [obj.Criterion; nodeNr criterion];
       obj.Comparison = [obj.Comparison; nodeNr  comparison]; 
       obj.SplittingValue = [obj.SplittingValue; nodeNr {splittingValue}];
       
       dataCriterionTrue = table2array(dataBranch(:,criterion));
       
       if comparison == 0
           IS = dataCriterionTrue < splittingValue;
           label = sprintf('%s %s < %5.2f',label,...
               dataBranch.Properties.VariableNames{criterion},splittingValue);
       elseif comparison == 2
           IS = dataCriterionTrue == splittingValue;
           label = sprintf('%s %s = %s',label,...
               dataBranch.Properties.VariableNames{criterion},splittingValue);
       end
           
       obj.NodeLabel = [obj.NodeLabel; nodeNr {label}];
       
       dataBranchTrue = dataBranch(IS,:); 
       targetBranchTrue = targetBranch(IS,:);
       dataBranchFalse = dataBranch(~IS,:); 
       targetBranchFalse = targetBranch(~IS,:);
        tmpTrue = obj.maxNodeNr + 1;
        tmpFalse = obj.maxNodeNr + 2;
        obj.maxNodeNr = obj.maxNodeNr + 2;
       [obj, nodes] = constructDecisionTree(obj,dataBranchTrue, targetBranchTrue, tmpTrue, 'T / ');
       obj.TrueNode = [obj.TrueNode; nodeNr tmpTrue];


       [obj, nodes] = constructDecisionTree(obj,dataBranchFalse, targetBranchFalse, tmpFalse, 'F / ');
       obj.FalseNode = [obj.FalseNode; nodeNr tmpFalse];

           
    end
        
    % evaluate splitting criterion
    function [criterion, comparison, splittingValue] =...
            getCriterion(obj, dataBranch, targetBranch)

        criterion = -1; 
        comparison = 0; 
        splitVar = 1e20;
        assigned = false;
        splittingValue = -1;
        

        
        for i = 1:size(dataBranch,2) % analyze variables
            if iscategorical(table2array(dataBranch(:,i)))
                uniqueValues = unique(table2array(dataBranch(:,i)));
                % The split with lower variance is selected as the criteria to split the population
                for j = 1:length(uniqueValues)
                    isValue = (table2array(dataBranch(:,i)) == uniqueValues(j));
                    predictionCValue =  mean(targetBranch(isValue));
                    split1 = covariance(obj, targetBranch(isValue),predictionCValue);
                    
                    predictionOValue =  mean(targetBranch(~isValue));
                    split2 = covariance(obj, targetBranch(~isValue),predictionOValue);
                    
                    
                    splitVarNode = sum(isValue)/size(dataBranch,1)*split1 + ... 
                    sum(~isValue)/size(dataBranch,1)*split2;
                
                    if splitVarNode < splitVar %|| (criterion == -1)
                        splitVar = splitVarNode; 
                        criterion = i;
                        splittingValue = uniqueValues(j);
                        comparison = 2;
                        assigned = true;
                    end
                end
            else
                splitValue = mean(table2array(dataBranch(:,i))); % split by mean
                isValue = (table2array(dataBranch(:,i)) < splitValue);
                predictionCValue =  mean(targetBranch(isValue));
                split1 = covariance(obj, targetBranch(isValue),predictionCValue);
                
                predictionOValue =  mean(targetBranch(~isValue));
                split2 = covariance(obj, targetBranch(~isValue),predictionOValue);
                
                splitVarNode = sum(isValue)/size(dataBranch,1)*split1 + ... 
                    sum(~isValue)/size(dataBranch,1)*split2;
                
                if splitVarNode < splitVar %|| (criterion == -1)
                    splitVar = splitVarNode; 
                    criterion = i;
                    splittingValue = splitValue;
                    comparison = 0;
                    assigned = true;
                end
            end
        end
    end
       % lets use MSE
    function err = covariance(obj, values, meanValue)
        err =0;
        
        for i=1:length(values)
            targetVal = values(i);
            err = err + (targetVal - meanValue)^2;
        end
        err = err / length(values);
    end
    function plotDTree(obj)
        
        
        nodes = [0 1; obj.TrueNode; obj.FalseNode];
        
        [sortedNodes, I] = sort(nodes(:,2));
        treearray = double(nodes(I,1)');
        treeplot(treearray);
        
        [x,y] = treelayout(treearray);
        nodeidx = sortedNodes;
        
        labelX = obj.NodeLabel;
        [sortedNodes, I] = sort(cell2mat(labelX(:,1)));
        labelsN = labelX(I,2);
        labels = cellfun(@num2str, labelsN, 'uniformoutput', 0);
        text(x(nodeidx), y(nodeidx) - 0.03, labels);
    end
   end
   
end