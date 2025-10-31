import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import searchUsers from '@salesforce/apex/BreezyRouterController.searchUsers';
import getRouterDetails from '@salesforce/apex/BreezyRouterController.getRouterDetails';
import getRouterMemberUserIds from '@salesforce/apex/BreezyRouterController.getRouterMemberUserIds';
import addUsersToRouter from '@salesforce/apex/BreezyRouterController.addUsersToRouter';
import removeUsersFromRouter from '@salesforce/apex/BreezyRouterController.removeUsersFromRouter';
import getUserRoles from '@salesforce/apex/BreezyRouterController.getUserRoles';
import getUserProfiles from '@salesforce/apex/BreezyRouterController.getUserProfiles';

export default class BreezyUserAssignment extends LightningElement {
    @api routerId;
    @api routerName;
    
    @track users = [];
    filteredUsers = [];
    @track selectedUserIds = [];
    @track selectedMemberIds = [];
    @track existingMemberUserIds = [];
    currentMembers = [];
    @track isLoading = false;
    @track dataVersion = 0; // Force refresh by changing this
    @track showTables = true; // Toggle to force complete re-render
    
    // Search and filter
    @track searchTerm = '';
    @track selectedRoleId = '';
    @track selectedProfileId = '';
    @track selectedDepartment = '';
    
    // Picklist options
    @track roleOptions = [];
    @track profileOptions = [];
    
    // Data table columns for all users
    columns = [
        {
            label: 'Name',
            fieldName: 'name',
            type: 'text',
            sortable: true
        },
        {
            label: 'Email',
            fieldName: 'email',
            type: 'email'
        },
        {
            label: 'Username',
            fieldName: 'username',
            type: 'text'
        },
        {
            label: 'Department',
            fieldName: 'department',
            type: 'text'
        },
        {
            label: 'Profile',
            fieldName: 'profileName',
            type: 'text'
        },
        {
            label: 'Role',
            fieldName: 'roleName',
            type: 'text'
        },
        {
            label: 'Status',
            fieldName: 'membershipStatus',
            type: 'text',
            cellAttributes: {
                class: { fieldName: 'statusClass' }
            }
        }
    ];
    
    // Data table columns for current members
    memberColumns = [
        {
            label: 'Name',
            fieldName: 'name',
            type: 'text',
            sortable: true
        },
        {
            label: 'Email',
            fieldName: 'email',
            type: 'email'
        },
        {
            label: 'Username',
            fieldName: 'username',
            type: 'text'
        },
        {
            label: 'Department',
            fieldName: 'department',
            type: 'text'
        },
        {
            label: 'Date Added',
            fieldName: 'createdDate',
            type: 'date',
            typeAttributes: {
                year: 'numeric',
                month: 'short',
                day: '2-digit'
            }
        },
        {
            label: 'Last Routed',
            fieldName: 'routedDate',
            type: 'date',
            typeAttributes: {
                year: 'numeric',
                month: 'short',
                day: '2-digit',
                hour: '2-digit',
                minute: '2-digit'
            },
            sortable: true
        }
    ];
    
    connectedCallback() {
        this.loadFilterOptions();
        if (this.routerId) {
            this.loadExistingMembers();
        }
        this.performSearch();
    }
    
    loadFilterOptions() {
        // Load roles
        getUserRoles()
            .then(result => {
                this.roleOptions = [
                    { label: '--All Roles--', value: '' },
                    ...result.map(role => ({ label: role.label, value: role.value }))
                ];
            })
            .catch(error => {
                console.error('Error loading roles:', error);
            });
        
        // Load profiles
        getUserProfiles()
            .then(result => {
                this.profileOptions = [
                    { label: '--All Profiles--', value: '' },
                    ...result.map(profile => ({ label: profile.label, value: profile.value }))
                ];
            })
            .catch(error => {
                console.error('Error loading profiles:', error);
            });
    }
    
    loadExistingMembers() {
        return getRouterMemberUserIds({ routerId: this.routerId })
            .then(result => {
                // Convert to plain array to avoid Proxy issues
                this.existingMemberUserIds = result ? [...result] : [];
                console.log('Existing member IDs loaded:', this.existingMemberUserIds);
                // Load full details for current members
                return this.loadCurrentMemberDetails();
            })
            .catch(error => {
                this.showToast('Error', 'Error loading existing members: ' + error.body.message, 'error');
                throw error;
            });
    }
    
    loadCurrentMemberDetails() {
        if (!this.routerId) {
            this.currentMembers = [];
            return Promise.resolve();
        }
        
        // Get router details including member information
        return getRouterDetails({ routerId: this.routerId })
            .then(result => {
                console.log('Loaded member details:', result.members);
                
                // FORCE datatable to refresh by clearing first
                this.currentMembers = [];
                
                // Use setTimeout to ensure clearing happens first
                return new Promise(resolve => {
                    setTimeout(() => {
                        // Map member data to display format
                        this.currentMembers = result.members.map(member => ({
                            id: member.userId,
                            name: member.userName,
                            email: member.userEmail,
                            username: member.userName,
                            department: '',
                            createdDate: member.createdDate,
                            routedDate: member.routedDate,
                            memberId: member.id
                        }));
                        this.dataVersion++; // Increment to force refresh
                        console.log('Current members updated:', this.currentMembers.length, 'Version:', this.dataVersion);
                        // Force complete re-render of tables
                        this.showTables = false;
                        setTimeout(() => {
                            this.showTables = true;
                            resolve();
                        }, 100);
                    }, 0);
                });
            })
            .catch(error => {
                console.error('Error loading current member details:', error);
                this.currentMembers = [];
                throw error;
            });
    }
    
    get hasUsers() {
        return this.filteredUsers && this.filteredUsers.length > 0;
    }
    
    get usersTableKey() {
        return `users-table-${this.dataVersion}`;
    }
    
    get membersTableKey() {
        return `members-table-${this.dataVersion}`;
    }
    
    get hasSelectedUsers() {
        return this.selectedUserIds && this.selectedUserIds.length > 0;
    }
    
    get isNoSelection() {
        return !this.hasSelectedUsers;
    }
    
    get selectedCount() {
        return this.selectedUserIds.length;
    }
    
    get addButtonLabel() {
        return `Add Selected (${this.selectedCount})`;
    }
    
    get removeButtonLabel() {
        return `Remove Selected (${this.selectedCount})`;
    }
    
    get hasCurrentMembers() {
        return this.currentMembers && this.currentMembers.length > 0;
    }
    
    get currentMemberCount() {
        return this.currentMembers ? this.currentMembers.length : 0;
    }
    
    get hasMemberSelection() {
        return this.selectedMemberIds && this.selectedMemberIds.length > 0;
    }
    
    get isNoMemberSelection() {
        return !this.hasMemberSelection;
    }
    
    get selectedMemberCount() {
        return this.selectedMemberIds.length;
    }
    
    get removeMembersButtonLabel() {
        return `Remove Selected (${this.selectedMemberCount})`;
    }
    
    // Search and filter handlers
    handleSearchChange(event) {
        this.searchTerm = event.target.value;
        this.performSearch();
    }
    
    handleRoleChange(event) {
        this.selectedRoleId = event.target.value;
        this.performSearch();
    }
    
    handleProfileChange(event) {
        this.selectedProfileId = event.target.value;
        this.performSearch();
    }
    
    handleDepartmentChange(event) {
        this.selectedDepartment = event.target.value;
        this.performSearch();
    }
    
    handleClearFilters() {
        this.searchTerm = '';
        this.selectedRoleId = '';
        this.selectedProfileId = '';
        this.selectedDepartment = '';
        this.performSearch();
    }
    
    performSearch() {
        this.isLoading = true;
        
        return searchUsers({
            searchTerm: this.searchTerm || '',
            roleId: this.selectedRoleId || '',
            profileId: this.selectedProfileId || '',
            department: this.selectedDepartment || ''
        })
            .then(result => {
                console.log('Search results:', result.length, 'Existing members:', this.existingMemberUserIds);
                
                // FORCE datatable to refresh by clearing first
                this.filteredUsers = [];
                
                // Use setTimeout to ensure clearing happens first
                return new Promise(resolve => {
                    setTimeout(() => {
                        // Convert existing member IDs to plain array for comparison
                        const memberIdArray = Array.isArray(this.existingMemberUserIds) 
                            ? this.existingMemberUserIds 
                            : [...this.existingMemberUserIds];
                        
                        console.log('Member ID array for comparison:', memberIdArray);
                        
                        // Add membership status to each user
                        this.filteredUsers = result.map(user => {
                            const isMember = memberIdArray.includes(user.id);
                            console.log(`User ${user.name} (${user.id}): isMember = ${isMember}`);
                            return {
                                ...user,
                                membershipStatus: isMember ? 'In Router' : 'Available',
                                statusClass: isMember ? 'slds-text-color_success' : ''
                            };
                        });
                        this.dataVersion++; // Increment to force refresh
                        console.log('Filtered users updated:', this.filteredUsers.length, 'Version:', this.dataVersion);
                        console.log('Sample user statuses:', this.filteredUsers.slice(0, 3).map(u => `${u.name}: ${u.membershipStatus}`));
                        this.isLoading = false;
                        resolve();
                    }, 0);
                });
            })
            .catch(error => {
                this.showToast('Error', 'Error searching users: ' + error.body.message, 'error');
                this.isLoading = false;
                throw error;
            });
    }
    
    // Row selection handler
    handleRowSelection(event) {
        this.selectedUserIds = event.detail.selectedRows.map(row => row.id);
    }
    
    // Add users to router
    handleAddUsers() {
        if (!this.routerId) {
            this.showToast('Error', 'Please select a router first', 'error');
            return;
        }
        
        if (this.selectedUserIds.length === 0) {
            this.showToast('Warning', 'Please select users to add', 'warning');
            return;
        }
        
        this.isLoading = true;
        
        addUsersToRouter({
            routerId: this.routerId,
            userIds: this.selectedUserIds
        })
            .then(result => {
                const addedCount = result;
                
                // Clear selections
                this.selectedUserIds = [];
                
                // Reload everything to ensure consistency
                return this.loadExistingMembers().then(() => addedCount);
            })
            .then((addedCount) => {
                // After members are reloaded, refresh the search results
                return this.performSearch().then(() => addedCount);
            })
            .then((addedCount) => {
                this.isLoading = false;
                this.showToast('Success', `Successfully added ${addedCount} user(s) to router`, 'success');
                
                // Dispatch event to refresh router details in parent
                this.dispatchEvent(new CustomEvent('usersadded', {
                    detail: { count: addedCount }
                }));
            })
            .catch(error => {
                this.showToast('Error', error.body ? error.body.message : error.message, 'error');
                this.isLoading = false;
            });
    }
    
    // Remove users from router (from top table)
    handleRemoveUsers() {
        if (!this.routerId) {
            this.showToast('Error', 'Please select a router first', 'error');
            return;
        }
        
        if (this.selectedUserIds.length === 0) {
            this.showToast('Warning', 'Please select users to remove', 'warning');
            return;
        }
        
        this.isLoading = true;
        
        removeUsersFromRouter({
            routerId: this.routerId,
            userIds: this.selectedUserIds
        })
            .then(result => {
                const removedCount = result;
                
                // Clear selections
                this.selectedUserIds = [];
                
                // Reload everything to ensure consistency
                return this.loadExistingMembers().then(() => removedCount);
            })
            .then((removedCount) => {
                // After members are reloaded, refresh the search results
                return this.performSearch().then(() => removedCount);
            })
            .then((removedCount) => {
                this.isLoading = false;
                this.showToast('Success', `Successfully removed ${removedCount} user(s) from router`, 'success');
                
                // Dispatch event to refresh router details in parent
                this.dispatchEvent(new CustomEvent('usersremoved', {
                    detail: { count: removedCount }
                }));
            })
            .catch(error => {
                this.showToast('Error', error.body ? error.body.message : error.message, 'error');
                this.isLoading = false;
            });
    }
    
    // Member row selection handler
    handleMemberRowSelection(event) {
        this.selectedMemberIds = event.detail.selectedRows.map(row => row.id);
    }
    
    // Remove members from router (from members table)
    handleRemoveMembers() {
        if (!this.routerId) {
            this.showToast('Error', 'Please select a router first', 'error');
            return;
        }
        
        if (this.selectedMemberIds.length === 0) {
            this.showToast('Warning', 'Please select members to remove', 'warning');
            return;
        }
        
        this.isLoading = true;
        
        removeUsersFromRouter({
            routerId: this.routerId,
            userIds: this.selectedMemberIds
        })
            .then(result => {
                const removedCount = result;
                
                // Clear selections
                this.selectedMemberIds = [];
                
                // Reload everything to ensure consistency
                return this.loadExistingMembers().then(() => removedCount);
            })
            .then((removedCount) => {
                // After members are reloaded, refresh the search results
                return this.performSearch().then(() => removedCount);
            })
            .then((removedCount) => {
                this.isLoading = false;
                this.showToast('Success', `Successfully removed ${removedCount} member(s) from router`, 'success');
                
                // Dispatch event to refresh router details in parent
                this.dispatchEvent(new CustomEvent('usersremoved', {
                    detail: { count: removedCount }
                }));
            })
            .catch(error => {
                this.showToast('Error', error.body ? error.body.message : error.message, 'error');
                this.isLoading = false;
            });
    }
    
    // Refresh members list
    handleRefreshMembers() {
        this.isLoading = true;
        
        this.loadExistingMembers()
            .then(() => {
                return this.performSearch();
            })
            .then(() => {
                this.isLoading = false;
                this.showToast('Success', 'Members list refreshed', 'success');
            })
            .catch(error => {
                this.isLoading = false;
                this.showToast('Error', 'Error refreshing members', 'error');
            });
    }
    
    // Utility: Show toast message
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}

