package com.app.demo.repository;
import com.app.demo.models.Order;
import com.app.demo.models.OrderStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface OrderRepository extends JpaRepository<Order,Long> {
    List<Order> findByStatusNot(OrderStatus orderStatus);
}
