package com.app.demo.repository;

import com.app.demo.models.MenuItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;


@Repository
public interface MenuItemRepository extends JpaRepository<MenuItem,Long> {

    Optional<MenuItem> findByname(String name);

    void deleteByname(String name);
}
