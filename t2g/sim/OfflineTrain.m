clear
global Snag;
global Svar;
global PathNum;
global Nap;
global Restart;
% global TrainRSS;
global SnagTrain;
global PathTrain;
global ApLoc;
global emp;
global trainrandp;
global StepSize;

Width = 200;
Height = 200;
St = 150;
S0 = 1;
Svar = 5; 
StepSize = 20;
Nap = 30; 
PathNum = 400;
Snag = 1;
Restart = 1;
emp = 0;


    
if Restart == 1
    
    ApLoc = [];
    ApLoc(:,1) = rand(Nap,1) * Width;
    ApLoc(:,2) = rand(Nap,1) * Height;
    PathTrain = [];
    for i = 1 : PathNum
%         TrainRSS(i).Path(1,:) = rand(1,2) * Width;
%         TrainRSS(i).Path(2,:) = rand(1,2) * Height;
        PathTrain(i,:) = [rand(1,2) * Width, rand(1,2) * Height];
        %PathTrain(i,:) = [[0,0] * Width, rand(1,2) * Height];
    end
end
%PathTrain(PathNum,:) = [rand(1,2) * Width, rand(1,2) * Height];

for i = 1 : PathNum
    %PathTrain(i,:) = [rand(1,2) * Width, rand(1,2) * Height];
    TrainRSS(i).Path(1,:) = PathTrain(i,1:2);
    TrainRSS(i).Path(2,:) = PathTrain(i,3:4);       
end

% for i = 1 : size(SegRSS, 1)
%     TrainRSS(i).Path = SegRSS(i).Segs;
% end


for i = 1 : PathNum
    temps = 0;
    for j = 2 : size(TrainRSS(i).Path, 2)
        dis = norm(TrainRSS(i).Path(:,j) - TrainRSS(i).Path(:,j-1));
        samplePoints = round(dis/StepSize) + 1;
        for s = 1 : samplePoints
            temps = temps +1;
            offsetX = (TrainRSS(i).Path(1, j) - TrainRSS(i).Path(1, j-1)) / samplePoints * (s-1);
            offsetY = (TrainRSS(i).Path(2, j) - TrainRSS(i).Path(2, j-1)) / samplePoints * (s-1);
            
            for k = 1 : Nap
                d = pdist2(ApLoc(k,:), [TrainRSS(i).Path(1, j-1) + offsetX, TrainRSS(i).Path(2, j-1) + offsetY]);
                TrainRSS(i).RSSs(k,temps) = St-S0-10*2*log(d/1)+normrnd(0,Svar);
            end
            TrainRSS(i).RSSs(k+1, temps) = TrainRSS(i).Path(1, j-1) + offsetX;
            TrainRSS(i).RSSs(k+2, temps) = TrainRSS(i).Path(2, j-1) + offsetY;
        end
    end
end
if Restart == 1
    trainrandp = [];
    for i = 1 : PathNum
        trainrandp(i).p = randperm(size(TrainRSS(i).RSSs, 2)*Nap);
    end
end

for i = 1 : PathNum
    for j = 1 : fix(Nap*size(TrainRSS(i).RSSs, 2)*emp)
        h = fix((trainrandp(i).p(j)-1)/size(TrainRSS(i).RSSs, 2))+1;
        w = trainrandp(i).p(j)-(h-1)*size(TrainRSS(i).RSSs, 2);
        if w > size(TrainRSS(i).RSSs, 2)
            w = size(TrainRSS(i).RSSs, 2);
        end
        if h > Nap
            h = Nap;
        end
        TrainRSS(i).RSSs(h,w) = -20;
    end
end

AllRSS = [];
for i = 1 : PathNum
    ee = [];
    for j = 1 : size(TrainRSS(i).RSSs, 2) - 1
        ee = [ee, TrainRSS(i).RSSs(Nap+1:Nap+2, j) - TrainRSS(i).RSSs(Nap+1:Nap+2, j+1) + [normrnd(0, Snag * StepSize); normrnd(0, Snag * StepSize)]];
    end
    ee = [ee, [10000; 10000]];
    AllRSS = [AllRSS, [TrainRSS(i).RSSs; ee]];
end



 
save OfflineTrain.mat
