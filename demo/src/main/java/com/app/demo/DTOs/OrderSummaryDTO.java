package com.app.demo.DTOs;

import com.app.demo.models.Order;
import com.app.demo.models.OrderItem;
import com.app.demo.models.OrderStatus;

import java.time.LocalDateTime;
import java.util.List;


public class OrderSummaryDTO {
    public Long orderId;
    public LocalDateTime date;
    public OrderStatus status;
    public List<OrderItem> items;  // changed from List<String> to List<OrderItem>

    public OrderSummaryDTO(Order order) {
        this.orderId = order.getId();
        this.date = order.getDate();
        this.status = order.getStatus();
        this.items = order.getOrderItems();  // directly assign the list of OrderItems
    }
}

