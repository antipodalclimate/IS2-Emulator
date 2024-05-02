subplot(211)

mean_bias = mean(SIC_bias_perimage,1);
mean_std = mean(SIC_bias_std_perimage,1);
mean_abs_bias = mean(SIC_abs_bias_perimage,1);

plot(1:n_crossings,mean_bias)
grid on; box on;
hold on

plot(1:n_crossings,mean_abs_bias,'k','linewidth',1)
plot(1:n_crossings,mean_bias + mean_std,'--k','linewidth',1)
plot(1:n_crossings,mean_bias - mean_std,'--k','linewidth',1)
xlim([1 20])
yline(.025,'--r');

subplot(223)
plot(1:n_crossings,squeeze(SIC_bias(1,:,:))','linewidth',0.2,'Color',[.8 .8 .8])
hold on
plot(1:n_crossings,mean(squeeze(SIC_bias(1,:,:)),2),'linewidth',1,'Color','k')
plot(1:n_crossings,mean(squeeze(SIC_bias(1,:,:)),2) + std(squeeze(SIC_bias(1,:,:)),[],1)','--','linewidth',1,'Color','k')
plot(1:n_crossings,mean(squeeze(SIC_bias(1,:,:)),2) - std(squeeze(SIC_bias(1,:,:)),[],1)','--','linewidth',1,'Color','k')
plot(1:n_crossings,(squeeze(SIC_bias(1,1,:))),'linewidth',1,'Color','b')
yline(0,'r')
grid on; box on;
xlim([1 20])

