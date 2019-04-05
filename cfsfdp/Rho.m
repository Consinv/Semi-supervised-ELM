clear all
close all
clc
%ѡȡ����
org=importdata('duichenflame90.mat');

%x��Ҫ��һ������ʵ����Ԥ����
[N,M]=size(org);
xx=org(:,1:M-1);
%xx=mapminmax(xx);

%����dist�������
dist=zeros(N,N);
for i=1:N-1
    for j=i+1:N
        dist(i,j)=norm(xx(i,:)-xx(j,:));
        dist(j,i)=norm(xx(i,:)-xx(j,:));
    end
end
%ѡȡdc
bb=0;
for i=1:N-1
    for j=i+1:N
        bb=bb+1;
        distence(bb)=dist(i,j);
    end
end
percent=0.01;
position=round(bb*percent/100);
sda=sort(distence);
dc=sda(position);

fprintf('Computing Rho with gaussian kernel of radius: %12.6f\n', dc);%����Rho���˹�˵İ뾶

%ȫ0��ʼ��rho����������rho���ܶ�
for i=1:N
  rho(i)=0.;
end

% Gaussian kernel��ԭ��G(x)=e^(-x^2)

for i=1:N-1
  for j=i+1:N
     rho(i)=rho(i)+exp(-(dist(i,j)/dc)*(dist(i,j)/dc));
     rho(j)=rho(j)+exp(-(dist(i,j)/dc)*(dist(i,j)/dc));
  end
end%�������£���i�̶�������jԽ��Խ��

maxd=max(max(dist));%������������ֵ��Ҳ����������

[rho_sorted,ordrho]=sort(rho,'descend');%�ܶȴӴ�С�������У�rho_sorted��������������ordrho�Ƕ�Ӧ�Ӵ�С���е��ܶȱ��
delta(ordrho(1))=-1.;%�����delta������Ϊ-1��������Ϊ��С����

nneigh(ordrho(1))=0;%���������ı��

%���ܶȱ��Լ����Ҿ�����̵ĵ㣬delta������룬nneigh������
for ii=2:N
   delta(ordrho(ii))=maxd;%ÿ��ѭ����ʼ���ҵ�������
   for jj=1:ii-1
     if(dist(ordrho(ii),ordrho(jj))<delta(ordrho(ii)))%�ڱ��Լ��ܶȴ�ĵ����Ҿ�����̵�
        delta(ordrho(ii))=dist(ordrho(ii),ordrho(jj));%deltaȡСֵ
        nneigh(ordrho(ii))=ordrho(jj);
     end
   end
end
delta(ordrho(1))=max(delta(:));%ȡ���������ֵ
disp('Generated file:DECISION GRAPH')%���ɾ���ͼ�ļ�������ܶȺ�delta����
disp('column 1:Density')
disp('column 2:Delta')

fid = fopen('DECISION_GRAPH', 'w');
for i=1:N
   fprintf(fid, '%6.2f %6.2f\n', rho(i),delta(i));
end

disp('Select a rectangle enclosing cluster centers')%ѡ��Χ�ƾ������ĵľ���
scrsz = get(0,'ScreenSize');%��ȡ���Էֱ��ʣ�����������Ļ��ȣ����ĸ�����Ļ�߶�
figure('Position',[6 72 scrsz(3)/4. scrsz(4)/1.3]);%position���ԣ�[left bottom width height]��ǰ������ԭ������λ��

subplot(2,1,1)%��������ͼ�����ǵ�һ��
%��ͼ������ȡ���tt��o�ͣ�k����ɫ��Marksize����ʶ����С��Markfacecolor����ʶ�������ɫ��markeredgecolor����ʶ����Ե��ɫ
tt=plot(rho(:),delta(:),'o','MarkerSize',3,'MarkerFaceColor','k','MarkerEdgeColor','k');
title ('Decision Graph','FontSize',15.0)
xlabel ('\rho')
ylabel ('\delta')


subplot(2,1,1)%�ڶ���
rect = getrect(1);%�ӵ�һ��ͼ�л�ȡ���ξ��󣬰���xmin,ymin,widht,height
rhomin=rect(1);%rhoΪx�ᣬ��������Сֵ
deltamin=rect(2);
NCLUST=0;%��������
for i=1:N%��ʼ��c1����
  cl(i)=-1;
end
%�������ĸ���
for i=1:N
    if ((rho(i)>rhomin) && (delta(i)>deltamin))
    %if ( ((rhomin+rect(3))>rho(i)>rhomin) && ((deltamin+rect(4))>delta(i)>deltamin))%ͳ�����ݵ�rho��delta��������Сֵ�õ㣬�Ծ��ο������Ϊ�߽�
     NCLUST=NCLUST+1;
     cl(i)=NCLUST;%�������ĵı�ţ�Ҳ����������һ��
     icl(NCLUST)=i;% ��ӳ��,�� NCLUST �� cluster ������Ϊ�� i �����ݵ�  
  end
end
fprintf('NUMBER OF CLUSTERS: %i \n', NCLUST);%Ⱥ����
disp('Performing assignation')%ִ�з���

%%%%%%%%%%%%%%%%%%%%%%%������ǩ%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% for i=1:NCLUST
%     cl(icl(i))=org(icl(i),M);
% end

%assignation
for i=1:N
  if (cl(ordrho(i))==-1)%=-1˵�����Ǵ�������
    cl(ordrho(i))=cl(nneigh(ordrho(i)));%����������������ܶȱ������࣬��Ϊrho������˳��ֵ��������ִ���
  end
end
%��ʼ��halo����⻷���֣�����

if (NCLUST>1)%���������Ŀ����1 
    for i=1:N
        halo(i)=cl(i);
    end
  for i=1:NCLUST%��ʼ��bord_rho����
    bord_rho(i)=0.;
  end

  %���������������������濪ʼ��ѡ�߽����򡣡�������������
  %���жԱ߽�Ķ��壺�Ǵ���㣬����������������ݵ�ľ���С��dc
  %Ȼ���ڱ߽��ҳ��ܶ����ĵ㣬�ܶȶ���Ϊpd
  %���д�������ܶȵ�Ϊ������ģ�С������ܶȵ�Ϊ���Σ�������
  for i=1:N-1
    for j=i+1:N
        
      if ((cl(i)~=cl(j))&& (dist(i,j)<=dc))%��ÿ�����ݵ�i�жϿɷ��Ϊ�߽�㣬������Ծͼ�¼һ��ƽ���ܶ�
        rho_aver=(rho(i)+rho(j))/2.;
        if (rho_aver>bord_rho(cl(i))) %��ƽ���ܶ��Ƿ�ɻ��ֺ��ĺ�����,������ܶ�
          bord_rho(cl(i))=rho_aver;
        end
        if (rho_aver>bord_rho(cl(j))) 
          bord_rho(cl(j))=rho_aver;
        end
      end
    end
  end
  for i=1:N
    if (rho(i)<bord_rho(cl(i)))%С�ڻ����ܶȣ����ж�Ϊ������halo����Ϊ0
      halo(i)=0;
    end
  end
end
for i=1:NCLUST%��ÿ���������
  nc=0;%����Ԫ�ظ���
  nh=0;%���к��ĸ���
  for j=1:N
    if (cl(j)==i) %����Ԫ�ظ���
      nc=nc+1;
    end
    if (halo(j)==i)%��������� 
      nh=nh+1;
    end
  end
  fprintf('CLUSTER: %i CENTER: %i ELEMENTS: %i CORE: %i HALO: %i \n', i,icl(i),nc,nh,nc-nh);
end

cmap=colormap;%��ȡһ��ͼ����ɫ�壬����һ��64*3�ľ���ȱʡֵ�����
for i=1:NCLUST
   ic=int8((i*64.)/(NCLUST*1.));%ic����ɫ���ã�ѡ��64��ĳһ�У���ֻ�ܻ���64�಻ͬ����ɫ��
   subplot(2,1,1)
   hold on
   plot(rho(icl(i)),delta(icl(i)),'o','MarkerSize',8,'MarkerFaceColor',cmap(ic,:),'MarkerEdgeColor',cmap(ic,:));
end


faa = fopen('CLUSTER_ASSIGNATION', 'w');
disp('Generated file:CLUSTER_ASSIGNATION')
disp('column 1:element id')
disp('column 2:cluster assignation without halo control')
disp('column 3:cluster assignation with halo control')
for i=1:N
   fprintf(faa, '%i %i %i\n',i,cl(i),halo(i));
end

%����Ĵ�����
%cl1=cl-1;
c3=cl'-org(:,M);
errornum3=sum(c3~=0);
fprintf('Clustering error numbers: %i  \n', errornum3); 
fprintf('Clustering accuracy rate: %f%%  \n', 100-100*errornum3/N); 
aa=[org(:,1:M-1),c3];