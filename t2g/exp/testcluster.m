%function[]=testcluster()
clear
%load OfflineTrain.mat
load GenerateDataFloor2.mat
global StepSize;
%global AllRSS;
global Nap;
StepSize = 1;
clear point;
%global Nap;
nodeerror = [];
%figure;
%for nodelength = 500: 500

    nodelength = min(250, size(AllRSS, 2));
    %randp = randperm(size(AllRSS,2));
    %AllRSSIndex = zeros(1, size(AllRSS,2));
    [AllRSSIndex, AllRSSC] = kmeans(AllRSS(1:Nap,:)', nodelength);
    %AllRSSIndex(1,randp) = AllRSSIndexRand;
    
    narray = [];
    nerrorarray = [];
    ClusterRSSArray = [];
    imshow('floor2.png')
    for i = 1 : nodelength
        %point(i).no = AllRSSNo(1, AllRSSIndex == i);
        point(i).pos = AllRSS(Nap+1:Nap+2, AllRSSIndex == i);
        point(i).number = size(point(i).pos, 2);
        narray = [narray; point(i).number];
        %point(i).clusterpos = mean(point(i).pos(:, find(point(i).no<=10)), 2);
        point(i).clusterpos = mean(point(i).pos, 2);
%         for k = 1 : Nap
%             d = pdist2(ApLoc(k,:), point(i).clusterpos');
%             point(i).expRSS(k,1) = St-S0-10*2*log(d /1);
%         end
        point(i).clusterRSS = mean(AllRSS(1:Nap, AllRSSIndex == i), 2);
        ClusterRSSArray = [ClusterRSSArray, point(i).clusterRSS];
        AllRSS(Nap+5, AllRSSIndex == i) = i;
        
       
        hold on
        cc = [rand rand rand];
        hold on
        plot(point(i).pos(1,:),point(i).pos(2,:),'.','color',cc,'markersize',10);
        hold on 
        plot(point(i).clusterpos(1),point(i).clusterpos(2),'color',cc,'marker','x','markersize',10);
        for j = 1 :size(point(i).pos, 2)
              hold on
              plot([point(i).clusterpos(1), point(i).pos(1, j)], [point(i).clusterpos(2), point(i).pos(2, j)],'-','color',cc);
            point(i).error(1, j) = norm(point(i).clusterpos - point(i).pos(:, j), 2);
        end
        %nerrorarray = [nerrorarray; norm(point(i).clusterRSS - point(i).expRSS, 2)];
    end

    clustererror = [];
    for i = 1 : nodelength
        clustererror = [clustererror, point(i).error];
    end

%    nodeerror = [nodeerror, mean(clustererror)/StepSize]
%end
% figure
% plot([1: 50: 501], nodeerror, 'bo-',  'linewidth', 2);
% xlabel('The number of clusters'); ylabel('Error of clustering (m)'); title('');
% set(gca,'FontSize',14)
% nn = unique(narray);
% for i = 1 : length(nn)
%     ne(i) = mean(nerrorarray(find(narray == nn(i))));
%     ns(i) = length(find(narray == nn(i)));
% end
% ne
% ns
% figure
% subplot(2,1,1)
% bar(ns);
% xlabel('The number of edges'); ylabel('The number of stances'); title('');
% subplot(2,1,2)
% bar(ne);
% xlabel('The number of edges'); ylabel('RSS average error (dbm)'); title('');
% save testedgefilter.mat
save testcluster.mat
%end
% hold on 
% plot(AllRSSC(:,1),C(:,2),'kx',...
%      'MarkerSize',15,'LineWidth',3) 