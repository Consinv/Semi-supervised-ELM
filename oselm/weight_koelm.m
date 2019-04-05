clc;
clear;

org=importdata('flame.txt');
NN=80;
[N,M]=size(org);

label=org(:,M);
%org2=mapminmax(org(:,1:M-1),0,4);
%org=[org2,label];

if ismember(0,org(:,M))
    org(:,M)=org(:,M)+1;  
end

r=randperm(N);
org=org(r,:);
X=org(:,1:M-1);
y=org(:,M);
labels=unique(y);
classnum=histc(y,labels);
labelednum=[];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
minnum=min(classnum);
for i=1:size(labels)
    labelednum=[labelednum;find(y==labels(i),minnum,'first')];
end
labeleddata=org(labelednum',:);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1:size(labels)
    labelednum=[labelednum;find(y==labels(i),round(0.1*classnum(i)),'first')];
end
labeleddata=org(labelednum',:);

testnum=[];
for i=1:size(labels)
    testnum=[testnum;find(y==labels(i),round(0.2*classnum(i)),'last')];
end
testdata=org(testnum',:);

unlabelednum=setdiff(r,[labelednum;testnum]');
unlabeleddata=org(unlabelednum,:);

org1=[labeleddata;unlabeleddata;testdata];
num02=size(labeleddata,1);
num08=num02+size(unlabeleddata,1);
numtest=size(testdata,1);

xx=org1(:,1:M-1);

%����dist�������
for i=1:num08
    for j=1:num08
        dist(i,j)=0;
    end
end
t1=clock;
for i=1:num08-1
    for j=i+1:num08
        dist(i,j)=norm(xx(i,:)-xx(j,:));
        dist(j,i)=norm(xx(i,:)-xx(j,:));
    end
end

%ѡȡdc
bb=0;
for i=1:num08-1
    for j=i+1:num08
        bb=bb+1;
        distence(bb)=dist(i,j);
    end
end
%%%%%%%%%%percentȷ��dc�ضϾ��룬Ӱ�����Ч��
percent=2;
position=round(bb*percent/100);
sda=sort(distence);
dc=sda(position);

fprintf('Computing Rho with gaussian kernel of radius: %12.6f\n', dc);%����Rho���˹�˵İ뾶

%ȫ0��ʼ��rho����������rho���ܶ�
for i=1:num08
  rho(i)=0.;
end

% Gaussian kernel��ԭ��G(x)=e^(-x^2)
for i=1:num08-1
  for j=i+1:num08
     rho(i)=rho(i)+exp(-(dist(i,j)/dc)*(dist(i,j)/dc));
     rho(j)=rho(j)+exp(-(dist(i,j)/dc)*(dist(i,j)/dc));
  end
end%�������£���i�̶�������jԽ��Խ��

maxd=max(max(dist));%������������ֵ��Ҳ����������

[rho_sorted,ordrho]=sort(rho,'descend');%�ܶȴӴ�С�������У�rho_sorted��������������ordrho�Ƕ�Ӧ�Ӵ�С���е��ܶȱ��
delta(ordrho(1))=-1.;%�����delta������Ϊ-1��������Ϊ��С����

nneigh(ordrho(1))=0;%���������ı��

%���ܶȱ��Լ����Ҿ�����̵ĵ㣬delta������룬nneigh������
for ii=2:num08
   delta(ordrho(ii))=maxd;%ÿ��ѭ����ʼ���ҵ�������
   for jj=1:ii-1
     if(dist(ordrho(ii),ordrho(jj))<delta(ordrho(ii)))%�ڱ��Լ��ܶȴ�ĵ����Ҿ�����̵�
        delta(ordrho(ii))=dist(ordrho(ii),ordrho(jj));%deltaȡСֵ
        nneigh(ordrho(ii))=ordrho(jj);
     end
   end
end
delta(ordrho(1))=max(delta(:));%ȡ���������ֵ
t2=clock;
%%%ѵ����ʼ%%%%%%%%%%train02�ٷ�֮20��ѵ������-train08�ٷ�֮80��ѵ������-traintest�ٷ�֮20�Ĳ�������
train02=org1(1:num02,:);
train022=train02;
train08=org1(1:num08,:);
traintest=org1(num08+1:end,:);

train02_fea=train02(:,1:M-1);
train02_lab=train02(:,M);
train02_lab_mat=ind2vec(train02_lab');%

%%elm��ѵ��
% NN=9;
[R,Q]=size(train02_fea);
IW=rand(NN,Q)*2-1;
B=rand(NN,1);
BM=repmat(B,1,R);
tempH1=IW*train02_fea'+BM;%
H1=1./(1+exp(-tempH1));
LW1=pinv(H1)'*train02_lab_mat';%


for i1=1:num02

     retrain=[];
     %��һ���
     if nneigh(i1)==0
         retrain=[];
     else
         retrain=[retrain;xx(nneigh(i1),1:M-1)];
     end
     
     
     %�ڶ����
     for i2=num02+1:num08
         if nneigh(i2)==i1
             retrain=[retrain;xx(nneigh(i2),1:M-1)];
         end               
     end 
     %%��ѵ���õ�LW1�����retrain��label
     [K,L]=size(retrain');
     BM1=repmat(B,1,L);
     tempH2=IW*retrain'+BM1;
     H2=1./(1+exp(-tempH2));
     Y2=(H2'*LW1)';
     
     temp_Y2=zeros(size(Y2));
     for i3=1:L
         [max_Y2,index2]=max(Y2(:,i3));%��i�����ֵ��index��ʾ��
         temp_Y2(index2,i3)=1;
     end
     Y22=vec2ind(temp_Y2);%-1
     
     retrain1=[retrain,Y22'];
     train022=[train022;retrain1]; %�ѻ�õı�ǩ�ӵ�ԭ��ѵ�����ϣ��γ�һ�����������ݼ�
     train023=unique(train022,'rows','stable');%ȥ��
     
     [k,l]=size(train023(:,1:M-1));
     BM2=repmat(B,1,k);%400*l
     tempH3=IW*train023(:,1:M-1)'+BM2;
     H3=1./(1+exp(-tempH3));
     LW2=pinv(H3)'*(ind2vec((train023(:,M))'))';%+1
     
     
end
 
%����������
test=org1(num08+1:N,:);
[ss,dd]=size(test(:,1:M-1)');
BM3=repmat(B,1,dd);%400*dd
tempH4=IW*test(:,1:M-1)'+BM3;%400*dd
H4=1./(1+exp(-tempH4));

Y4=(H4'*LW2)';%dd*1

temp_Y4=zeros(size(Y4));
    for i2 = 1:dd
        [max_Y4,index4] = max(Y4(:,i2));%��i�����ֵ��index��ʾ��
        temp_Y4(index4,i2) = 1;
    end
Y44=vec2ind(temp_Y4);

t3=clock;

c2=Y44'-test(:,M);
errornum2=sum(c2~=0);
fprintf('testing error numbers: %i  \n', errornum2); 
fprintf('testing accuracy rate: %f%%  \n', 100-100*errornum2/numtest); 

fprintf('time of computing distance: %f  \n', etime(t2,t1)); 
fprintf('time of training: %f  \n', etime(t3,t2)); 
fprintf('time of all: %f  \n', etime(t3,t1)); 