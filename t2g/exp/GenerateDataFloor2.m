%function [] = GenerateDataFloor2(TrainArray, TestArray)
global Nap;
global StepSize;
load Seq2.mat
TrainArray = [1:12];
TestArray = [];
%global AllRSS;
StepSize = 1;

% TestFre(1).test = [7:8]; % 60-60
% TestFre(1).train = [1:6];
% TestFre(2).test = [10]; % 10-10
% TestFre(2).train = [9];
% TestFre(3).test = [9,10]; % 60-10
% TestFre(3).train = [1:8];
% TestFre(4).test = [7:8]; % 10-60
% TestFre(4).train = [9,10];
% TestFre(5).test = [10]; % 60,10-10
% TestFre(5).train = [1:9];
% TestFre(6).test = [7:8]; % 60,10-60
% TestFre(6).train = [5:6,9,10];
% TestPose(1).train = [1,3,4,5,6,9,10]; %hand-hand
% TestPose(1).test = [7,8]; 
% TestPose(2).train = [1,3,4,5,6,7,8,9]; %hand-pocket
% TestPose(2).test = [2,10]; 
% TestPose(3).train = [2,10]; %pocket-hand
% TestPose(3).test = [7,8]; 
% TestDate(1).train = [1,2,9,10]; %28-2
% TestDate(1).test = [3:8]; 
% TestDate(2).train = [3:8]; %2-28
% TestDate(2).test = [1,2,9,10]; 
%for mm = 1: 2%size(TestDate,1)
% FPErrorArray = [];
% G2OErrorArray = [];
% FPMeanArray = [];
% G2OMeanArray = [];
% for mm = 10: 10%10%10
%     mm
%   mm = 10;
%mm
% TestArray = [];
% %TestArray = TestChoose(mm, :);
% TrainArray = setdiff([1:12],TestArray);
% mm
% TestArray = TestDate(mm).test;
% TrainArray = TestDate(mm).train;

% TrainArray = [1:8,10];
% TestArray = [9];

PathNumTrain = length(TrainArray);
% RSStPotDB = [];
% for i = 1 : PathNumTrain
%     RSStPotDB = [Seq2(TrainArray(i)).RSS(:, 1:Nap)'; Seq2(TrainArray(i)).RSS(:, Nap+1:Nap+2)'];%FP λ����ȷ
% end

AllRSS = [];
AllRSSNo = [];
%nnarray = [];

for i = 1 : PathNumTrain
    ee = [];
    for j = 1 : size(Seq2(TrainArray(i)).RSS, 1) - 1
        ee = [ee, Seq2(TrainArray(i)).RSS(j, Nap+3:Nap+4)' - Seq2(TrainArray(i)).RSS(j+1,Nap+3:Nap+4)'];
    end
    ee = [ee, [10000; 10000]];
    AllRSS = [AllRSS, [Seq2(TrainArray(i)).RSS(:,1:Nap+2)'; ee]];
    AllRSSNo = [AllRSSNo, TrainArray(i)*ones(1,size(ee, 2))];
end



% figure% StepSize = 1;
% testcluster(AllRSS);
% testedgefilter;
% [pointpos,g2opos,g2oRSS]=testwifi;
% %load testwifi.mat
% PathNumTest = length(TestArray);
% FPArray = [];
% G2OArray = [];
% imshow('floor2.png')
% for j = 1 : PathNumTest
%     FPPosArray = [];
%     G2OPosArray = [];
%     for t = 1 : size(Seq2(TestArray(j)).RSS, 1)
%         %FPPos = KNN(Seq2(TestArray(j)).RSS(t,1:Nap)', g2oRSS(1:Nap,:), pointpos(1:2,:), 1);
%         FPPos = KNN(Seq2(TestArray(j)).RSS(t,1:Nap)', RSStPotDB(1:Nap,:), RSStPotDB(Nap+1:Nap+2,:), 1);
%         FPError = norm(Seq2(TestArray(j)).RSS(t,Nap+1:Nap+2)'-FPPos, 2);
%         FPArray = [FPArray; FPError];
%         FPPosArray = [FPPosArray, FPPos];
%         G2OPos = KNN(Seq2(TestArray(j)).RSS(t,1:Nap)', g2oRSS(1:Nap,:), g2opos(1:2,:), 1);
%         G2OError = norm(Seq2(TestArray(j)).RSS(t,Nap+1:Nap+2)'-G2OPos, 2);
%         G2OArray = [G2OArray; G2OError];
%         G2OPosArray = [G2OPosArray, G2OPos];
%     end
%                 hold on
%                 plot(Seq2(TestArray(j)).RSS(:,Nap+1)',Seq2(TestArray(j)).RSS(:,Nap+2)','gs-', 'linewidth',2);
%                 hold on
%                 plot(FPPosArray(1,:),FPPosArray(2,:),'b+-','linewidth', 2)
%                 hold on
%                 plot(G2OPosArray(1,:),G2OPosArray(2,:),'mo-','linewidth', 2)
% 
% end
% G2OErrorArray = [G2OErrorArray; G2OArray];
% FPErrorArray = [FPErrorArray; FPArray];
% G2OMeanArray = [G2OMeanArray; mean(G2OArray)];
% FPMeanArray = [FPMeanArray; mean(FPArray)];
% 
% end
% 
% set(cdfplot(FPErrorArray / 30), 'linewidth', 1,'color', 'b', 'marker', '+');
% hold on
% set(cdfplot(G2OErrorArray / 30), 'linewidth', 1, 'color', 'm', 'marker', 'o');
% legend('Fingerprint map','Graph model');
% xlabel('Locating errors(m)'); ylabel('CDF'); title('');

% figure
% bar([FPMeanArray, G2OMeanArray]/30);
% legend('Fingerprint map','Graph model');
% ylabel('Locating errors(m)');
% xlabel('Test Group');
% set(gca,'XTickLabel',{'28/01/19-02/02/19','02/02/19-28/01/19'},'FontSize',12)
% set(gca,'XTickLabel',{'High-High','Low-Low','High-Low','Low-High','High,Low-Low','High,Low-High'},'FontSize',8)
% %set(gca,'XTickLabel',{'Hand-Hand','Hand-Pocket','Pocket-Hand'},'FontSize',12)

save GenerateDataFloor2.mat
%end
% for i = 1 : 1
%     rr = [];
%     rr = AllRSS([Nap+1,Nap+2,Nap+5],find(AllRSSNo == i));
%     rru = [];
%     rru = unique(rr(3,:));
%     for j = 1 : length(rru)
%         xy = [];
%         cc = [rand rand rand]
%         xy = rr(1:2, find(rr(3,:) == rru(j)));
%         hold on
%         plot(xy(1,:)+i*10,xy(2,:)+i*10,'color',cc)
%     end
% end