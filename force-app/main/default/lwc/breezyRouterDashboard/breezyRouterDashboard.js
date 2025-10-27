/**
 * @description Lightning Web Component for BreezyRouter Dashboard & Analytics
 * Provides comprehensive router statistics, member analytics, and routing insights
 * @author BreezyRouter Team
 * @date 2025
 */
import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getDashboardStats from '@salesforce/apex/BreezyRouterController.getDashboardStats';
import getRouterAnalytics from '@salesforce/apex/BreezyRouterController.getRouterAnalytics';
import getRoutingFrequency from '@salesforce/apex/BreezyRouterController.getRoutingFrequency';

export default class BreezyRouterDashboard extends LightningElement {
    @track dashboardStats = {};
    @track routerAnalytics = [];
    @track routingFrequency = [];
    @track isLoading = true;
    @track selectedTimeRange = '30'; // Default to last 30 days
    
    timeRangeOptions = [
        { label: 'Last 7 Days', value: '7' },
        { label: 'Last 30 Days', value: '30' },
        { label: 'Last 90 Days', value: '90' },
        { label: 'Last Year', value: '365' }
    ];
    
    wiredDashboardStats;
    wiredRouterAnalytics;
    wiredRoutingFrequency;
    
    // Wire methods
    @wire(getDashboardStats)
    wiredDashboard(result) {
        this.wiredDashboardStats = result;
        if (result.data) {
            this.dashboardStats = result.data;
            this.isLoading = false;
        } else if (result.error) {
            this.showToast('Error', 'Error loading dashboard stats: ' + result.error.body.message, 'error');
            this.isLoading = false;
        }
    }
    
    @wire(getRouterAnalytics, { timeRange: '$selectedTimeRange' })
    wiredAnalytics(result) {
        this.wiredRouterAnalytics = result;
        if (result.data) {
            this.routerAnalytics = result.data;
        } else if (result.error) {
            this.showToast('Error', 'Error loading router analytics: ' + result.error.body.message, 'error');
        }
    }
    
    @wire(getRoutingFrequency, { timeRange: '$selectedTimeRange' })
    wiredFrequency(result) {
        this.wiredRoutingFrequency = result;
        if (result.data) {
            this.routingFrequency = result.data;
        } else if (result.error) {
            this.showToast('Error', 'Error loading routing frequency: ' + result.error.body.message, 'error');
        }
    }
    
    // Computed properties
    get totalRouters() {
        return this.dashboardStats.totalRouters || 0;
    }
    
    get totalMembers() {
        return this.dashboardStats.totalMembers || 0;
    }
    
    get activeMembers() {
        return this.dashboardStats.activeMembers || 0;
    }
    
    get inactiveMembers() {
        return this.dashboardStats.inactiveMembers || 0;
    }
    
    get totalRoutings() {
        return this.dashboardStats.totalRoutings || 0;
    }
    
    get averageRoutingsPerDay() {
        return this.dashboardStats.averageRoutingsPerDay || 0;
    }
    
    get hasRouterAnalytics() {
        return this.routerAnalytics && this.routerAnalytics.length > 0;
    }
    
    get hasRoutingFrequency() {
        return this.routingFrequency && this.routingFrequency.length > 0;
    }
    
    get activePercentage() {
        if (this.totalMembers === 0) return 0;
        return Math.round((this.activeMembers / this.totalMembers) * 100);
    }
    
    get inactivePercentage() {
        if (this.totalMembers === 0) return 0;
        return Math.round((this.inactiveMembers / this.totalMembers) * 100);
    }
    
    // Event handlers
    handleTimeRangeChange(event) {
        this.selectedTimeRange = event.target.value;
        this.refreshData();
    }
    
    handleRefresh() {
        this.isLoading = true;
        this.refreshData();
    }
    
    refreshData() {
        return Promise.all([
            refreshApex(this.wiredDashboardStats),
            refreshApex(this.wiredRouterAnalytics),
            refreshApex(this.wiredRoutingFrequency)
        ]).then(() => {
            this.isLoading = false;
            this.showToast('Success', 'Dashboard data refreshed', 'success');
        }).catch(error => {
            this.isLoading = false;
            this.showToast('Error', 'Error refreshing data: ' + error.body.message, 'error');
        });
    }
    
    // Helper methods
    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        }));
    }
}
