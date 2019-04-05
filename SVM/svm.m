clear all
close all
clc

%function [ classfication ] = test( train,test1 )

%load chapter12_wine.mat                       %��������
%ѡȡ����
org=importdata('IRIS���ݼ�.xls');

[N,M]=size(org);
num02=round(N*0.2);
num08=round(N*0.8);
numtest=N-num08;

r=randperm(size(org,1));%1��ʾ��
org1=org(r,:);

train=org1(1:num02,1:M-1);
train_group=org1(1:num02,M);
test1=org1(num08+1:N,1:M-1);
test_group=org1(num08+1:N,M);

%train=[wine(1:30,:);wine(60:95,:);wine(131:153,:)]; %ѡȡѵ������
%train_group=[wine_labels(1:30);wine_labels(60:95); wine_labels(131:153)];%ѡȡѵ����������ʶ
%test=[wine(31:59,:);wine(96:130,:);wine(154:178,:)];%ѡȡ��������
%test_group=[wine_labels(31:59);wine_labels(96:130); wine_labels(154:178)]; %ѡȡ������������ʶ

%����Ԥ������matlab�Դ���mapminmax��ѵ�����Ͳ��Լ���һ������[0,1]֮��
%ѵ�����ݴ���
[train,pstrain] = mapminmax(train');
% ��ӳ�亯���ķ�Χ�����ֱ���Ϊ0��1
pstrain.ymin = 0;
pstrain.ymax = 1;
% ��ѵ��������[0,1]��һ��
[train,pstrain] = mapminmax(train,pstrain);
% �������ݴ���
[test1,pstest] = mapminmax(test1');
% ��ӳ�亯���ķ�Χ�����ֱ���Ϊ0��1
pstest.ymin = 0;
pstest.ymax = 1;
% �Բ��Լ�����[0,1]��һ��
[test1,pstest] = mapminmax(test1,pstest);
% ��ѵ�����Ͳ��Լ�����ת��,�Է���libsvm����������ݸ�ʽҪ��
train = train';
test1 = test1';

%Ѱ������c��g
%����ѡ��c&g �ı仯��Χ�� 2^(-10),2^(-9),...,2^(10)
%[bestacc,bestc,bestg] = SVMcgForClass(train_group,train,-10,10,-10,10);
%��ϸѡ��c �ı仯��Χ�� 2^(-2),2^(-1.5),...,2^(4), g �ı仯��Χ�� 2^(-4),2^(-3.5),...,2^(4)
[bestacc,bestc,bestg] = SVMcgForClass(train_group,train,-2,4,-4,4,3,0.5,0.5,0.9);

%ѵ��ģ��
cmd = ['-c ',num2str(bestc),' -g ',num2str(bestg)];
model=svmtrain(train_group,train,cmd);
disp(cmd);

%���Է���
[predict_label, accuracy, dec_values]=svmpredict(test_group,test1,model);

%��ӡ���Է�����
figure;
hold on;
plot(test_group,'o');
plot(predict_label,'r*');
legend('ʵ�ʲ��Լ�����','Ԥ����Լ�����');
title('���Լ���ʵ�ʷ����Ԥ�����ͼ','FontSize',10);
%end