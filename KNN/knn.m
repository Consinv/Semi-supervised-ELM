
%%
clc
clear
close all

%function KNNdatgingTest
%%%ѡȡ����
org=importdata('jain.txt');
[N,M]=size(org);
%����Ԥ����
r=randperm(size(org,1));%1��ʾ��
data=org(r,:);
%inx=org(0.1*M+1:end,1:M-1);
%labels=org1(1:0.1*M,M);
%data=org1(1:0.1*M,1:M-1);

dataMat = mapminmax(data(:,1:M-1));
labels = data(:,M);
len = round((size(dataMat,1))*0.3);
k = 9;
error = 0;
% �������ݱ���
Ratio = 2./3;
numTest = round(Ratio * len);
% ��һ������
newdataMat=mapminmax(dataMat);

% ����
for i = 1:numTest
    classifyresult = KNN(newdataMat(i,:),newdataMat(numTest:len,:),labels(numTest:len,:),k);
    %fprintf('���Խ��Ϊ��%d  ��ʵ���Ϊ��%d\n',[classifyresult labels(i)]);
    if(classifyresult~=labels(i))
        error = error+1;
    end
end
  fprintf('��ȷ��Ϊ��%f%% \n',100-100*error/(numTest));
%end

function relustLabel = KNN(inx,data,labels,k)
%   inx Ϊ ����������ݣ�dataΪ�������ݣ�labelsΪ������ǩ
[datarow , datacol] = size(data);%�����Ĵ�С
diffMat = repmat(inx,[datarow,1]) - data ;%���������ظ�datarow��
distanceMat = sqrt(sum(diffMat.^2,2));%
[B , IX] = sort(distanceMat,'ascend');
len = min(k,length(B));
relustLabel = mode(labels(IX(1:len)));
end
