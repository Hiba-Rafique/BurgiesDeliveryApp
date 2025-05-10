package com.app.demo.models;
import jakarta.persistence.*;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

@Entity
@Table(name = "admins")
public class Admin extends User {
    @OneToMany(mappedBy = "createdBy", cascade = CascadeType.ALL)
    private List<MenuItem> createdMenuItems;

    @Temporal(TemporalType.TIMESTAMP)
    private Date lastActionTime;

    public Admin(){}
    public Admin(List<MenuItem> createdMenuItems, Date lastActionTime) {
        this.createdMenuItems = createdMenuItems;
        this.lastActionTime = lastActionTime;
    }

    public List<MenuItem> getCreatedMenuItems() { return createdMenuItems; }
    public void setCreatedMenuItems(List<MenuItem> createdMenuItems) { this.createdMenuItems = createdMenuItems; }

    public Date getLastActionTime() { return lastActionTime; }
    public void setLastActionTime(Date lastActionTime) { this.lastActionTime = lastActionTime; }
}
